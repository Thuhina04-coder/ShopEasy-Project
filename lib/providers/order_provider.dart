import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];
  String? _userId;
  Timer? _statusTimer;
  final _uuid = const Uuid();
  final _db = DatabaseHelper.instance;

  List<Order> get orders => List.unmodifiable(_orders.reversed.toList());

  Future<void> loadForUser(String userId) async {
    _userId = userId;
    _orders.clear();

    final orderRows = await _db.getOrders(userId);

    for (final row in orderRows) {
      final orderId = row['id'] as String;
      final itemRows = await _db.getOrderItems(orderId);

      final items = itemRows.map((ir) {
        final product = Product(
          id: ir['product_id'] as String,
          name: ir['product_name'] as String,
          description: '',
          price: (ir['product_price'] as num).toDouble(),
          imageUrl: ir['product_image'] as String,
          categoryId: '',
          vendor: (ir['product_vendor'] as String?) ?? '',
        );
        return CartItem(product: product, quantity: ir['quantity'] as int);
      }).toList();

      final addressMap =
          jsonDecode(row['shipping_address'] as String) as Map<String, dynamic>;

      _orders.add(Order(
        id: orderId,
        items: items,
        subtotal: (row['subtotal'] as num).toDouble(),
        shippingFee: (row['shipping_fee'] as num).toDouble(),
        total: (row['total'] as num).toDouble(),
        shippingAddress: Address.fromMap(addressMap),
        paymentMethod: row['payment_method'] as String,
        status: OrderStatus.values.byName(row['status'] as String),
        createdAt: DateTime.parse(row['created_at'] as String),
        deliveredAt: row['delivered_at'] != null
            ? DateTime.parse(row['delivered_at'] as String)
            : null,
      ));
    }

    _startStatusTimer();
    notifyListeners();
  }

  void clearForLogout() {
    _orders.clear();
    _userId = null;
    _statusTimer?.cancel();
    notifyListeners();
  }

  Future<Order> placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double shippingFee,
    required double total,
    required Address shippingAddress,
    required String paymentMethod,
  }) async {
    final orderId = 'ORD-${_uuid.v4().substring(0, 8).toUpperCase()}';

    final order = Order(
      id: orderId,
      items: items
          .map((i) => CartItem(product: i.product, quantity: i.quantity))
          .toList(),
      subtotal: subtotal,
      shippingFee: shippingFee,
      total: total,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now(),
    );

    final itemMaps = items
        .map((i) => {
              'product_id': i.product.id,
              'product_name': i.product.name,
              'product_image': i.product.imageUrl,
              'product_vendor': i.product.vendor,
              'product_price': i.product.price,
              'quantity': i.quantity,
            })
        .toList();

    await _db.insertOrder(
      orderId: orderId,
      userId: _userId!,
      subtotal: subtotal,
      shippingFee: shippingFee,
      total: total,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      status: 'confirmed',
      createdAt: order.createdAt,
      items: itemMaps,
    );

    _orders.add(order);
    _startStatusTimer();
    notifyListeners();
    return order;
  }

  Future<void> reorder(Order order) async {
    await placeOrder(
      items: order.items,
      subtotal: order.subtotal,
      shippingFee: order.shippingFee,
      total: order.total,
      shippingAddress: order.shippingAddress,
      paymentMethod: order.paymentMethod,
    );
  }

  void _startStatusTimer() {
    _statusTimer?.cancel();
    final hasActiveOrders = _orders.any((o) =>
        o.status != OrderStatus.delivered &&
        o.status != OrderStatus.cancelled);
    if (!hasActiveOrders) return;

    _statusTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _progressOrderStatuses();
    });
  }

  Future<void> _progressOrderStatuses() async {
    bool changed = false;
    final now = DateTime.now();

    for (int i = 0; i < _orders.length; i++) {
      final order = _orders[i];
      if (order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled) {
        continue;
      }

      final elapsed = now.difference(order.createdAt).inSeconds;
      OrderStatus? newStatus;

      if (order.status == OrderStatus.confirmed && elapsed >= 30) {
        newStatus = OrderStatus.processing;
      } else if (order.status == OrderStatus.processing && elapsed >= 60) {
        newStatus = OrderStatus.shipped;
      } else if (order.status == OrderStatus.shipped && elapsed >= 120) {
        newStatus = OrderStatus.delivered;
      }

      if (newStatus != null) {
        final deliveredAt =
            newStatus == OrderStatus.delivered ? now : null;
        _orders[i] = order.copyWith(
          status: newStatus,
          deliveredAt: deliveredAt,
        );
        await _db.updateOrderStatus(
            order.id, newStatus.name, deliveredAt);
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
      final hasActive = _orders.any((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled);
      if (!hasActive) {
        _statusTimer?.cancel();
      }
    }
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../utils/constants.dart';
import '../services/database_helper.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  String? _userId;

  final _db = DatabaseHelper.instance;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get shippingFee =>
      subtotal >= AppConstants.freeShippingThreshold
          ? 0
          : AppConstants.shippingFee;

  double get total => subtotal + shippingFee;

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantity(String productId) {
    final item = _items.where((i) => i.product.id == productId).firstOrNull;
    return item?.quantity ?? 0;
  }

  Future<void> loadForUser(String userId) async {
    _userId = userId;
    _items.clear();

    final rows = await _db.getCartItemsRaw(userId);
    for (final row in rows) {
      final product = Product.fromDbMap(row);
      final quantity = row['quantity'] as int;
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void clearForLogout() {
    _items.clear();
    _userId = null;
    notifyListeners();
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    if (_userId != null) {
      await _db.addToCart(_userId!, product.id, quantity);
    }
    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    if (_userId != null) {
      await _db.removeFromCart(_userId!, productId);
    }
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
        if (_userId != null) {
          await _db.removeFromCart(_userId!, productId);
        }
      } else {
        _items[index].quantity = quantity;
        if (_userId != null) {
          await _db.updateCartQuantity(_userId!, productId, quantity);
        }
      }
      notifyListeners();
    }
  }

  Future<void> incrementQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      if (_userId != null) {
        await _db.updateCartQuantity(
            _userId!, productId, _items[index].quantity);
      }
      notifyListeners();
    }
  }

  Future<void> decrementQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        if (_userId != null) {
          await _db.updateCartQuantity(
              _userId!, productId, _items[index].quantity);
        }
      } else {
        _items.removeAt(index);
        if (_userId != null) {
          await _db.removeFromCart(_userId!, productId);
        }
      }
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    if (_userId != null) {
      await _db.clearCart(_userId!);
    }
    notifyListeners();
  }
}

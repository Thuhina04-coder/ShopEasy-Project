import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/product.dart';
import '../models/category.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shopeasy.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    // Web (WASM): use a simple filename; path joining differs from mobile/desktop.
    final path = kIsWeb ? fileName : p.join(await getDatabasesPath(), fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT DEFAULT '',
        avatar_color INTEGER DEFAULT ${User.avatarColors[0]}
      )
    ''');

    await db.execute('''
      CREATE TABLE addresses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        label TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address_line1 TEXT NOT NULL,
        address_line2 TEXT DEFAULT '',
        city TEXT NOT NULL,
        province TEXT NOT NULL,
        postal_code TEXT NOT NULL,
        is_default INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        image_url TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        original_price REAL,
        image_url TEXT NOT NULL,
        image_urls TEXT DEFAULT '[]',
        category_id TEXT NOT NULL,
        rating REAL DEFAULT 0,
        review_count INTEGER DEFAULT 0,
        stock_count INTEGER DEFAULT 100,
        vendor TEXT DEFAULT 'ShopEasy',
        specifications TEXT DEFAULT '{}'
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER DEFAULT 1,
        UNIQUE(user_id, product_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        subtotal REAL NOT NULL,
        shipping_fee REAL NOT NULL,
        total REAL NOT NULL,
        shipping_address TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT DEFAULT 'confirmed',
        created_at TEXT NOT NULL,
        delivered_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_image TEXT NOT NULL,
        product_vendor TEXT DEFAULT '',
        product_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    for (final category in _seedCategories) {
      await db.insert('categories', category.toDbMap());
    }
    for (final product in _seedProducts) {
      await db.insert('products', product.toDbMap());
    }
  }

  // ─── User Operations ──────────────────────────────────────

  Future<String?> insertUser({
    required String id,
    required String email,
    required String passwordHash,
    required String fullName,
    required String phone,
    int? avatarColor,
  }) async {
    final db = await database;
    try {
      await db.insert('users', {
        'id': id,
        'email': email.toLowerCase(),
        'password_hash': passwordHash,
        'full_name': fullName,
        'phone': phone,
        'avatar_color': avatarColor ?? User.avatarColors[0],
      });
      return id;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  // ─── Address Operations ───────────────────────────────────

  Future<void> insertAddress(String userId, Address address) async {
    final db = await database;
    if (address.isDefault) {
      await db.update(
        'addresses',
        {'is_default': 0},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
    await db.insert('addresses', address.toDbMap(userId),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Address>> getAddresses(String userId) async {
    final db = await database;
    final result = await db.query(
      'addresses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((map) => Address.fromMap(map)).toList();
  }

  Future<void> updateAddress(String userId, Address address) async {
    final db = await database;
    if (address.isDefault) {
      await db.update(
        'addresses',
        {'is_default': 0},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
    await db.update(
      'addresses',
      address.toDbMap(userId),
      where: 'id = ?',
      whereArgs: [address.id],
    );
  }

  Future<void> deleteAddress(String addressId) async {
    final db = await database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [addressId]);
  }

  // ─── Product & Category Operations ────────────────────────

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((map) => Product.fromDbMap(map)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final db = await database;
    final result =
        await db.query('products', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Product.fromDbMap(result.first) : null;
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return result.map((map) => Product.fromDbMap(map)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final lowerQuery = '%${query.toLowerCase()}%';
    final result = await db.rawQuery(
      'SELECT * FROM products WHERE LOWER(name) LIKE ? OR LOWER(description) LIKE ? OR LOWER(vendor) LIKE ?',
      [lowerQuery, lowerQuery, lowerQuery],
    );
    return result.map((map) => Product.fromDbMap(map)).toList();
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories');
    return result.map((map) => Category.fromDbMap(map)).toList();
  }

  // ─── Cart Operations ──────────────────────────────────────

  Future<void> addToCart(String userId, String productId, int quantity) async {
    final db = await database;
    final existing = await db.query(
      'cart_items',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );

    if (existing.isNotEmpty) {
      final currentQty = existing.first['quantity'] as int;
      await db.update(
        'cart_items',
        {'quantity': currentQty + quantity},
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
      );
    } else {
      await db.insert('cart_items', {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<void> updateCartQuantity(
      String userId, String productId, int quantity) async {
    final db = await database;
    if (quantity <= 0) {
      await removeFromCart(userId, productId);
    } else {
      await db.update(
        'cart_items',
        {'quantity': quantity},
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
      );
    }
  }

  Future<void> removeFromCart(String userId, String productId) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
  }

  Future<void> clearCart(String userId) async {
    final db = await database;
    await db.delete('cart_items', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getCartItemsRaw(String userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ci.product_id, ci.quantity, p.*
      FROM cart_items ci
      INNER JOIN products p ON ci.product_id = p.id
      WHERE ci.user_id = ?
    ''', [userId]);
  }

  // ─── Order Operations ─────────────────────────────────────

  Future<void> insertOrder({
    required String orderId,
    required String userId,
    required double subtotal,
    required double shippingFee,
    required double total,
    required Address shippingAddress,
    required String paymentMethod,
    required String status,
    required DateTime createdAt,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('orders', {
        'id': orderId,
        'user_id': userId,
        'subtotal': subtotal,
        'shipping_fee': shippingFee,
        'total': total,
        'shipping_address': jsonEncode(shippingAddress.toMap()),
        'payment_method': paymentMethod,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      });

      for (final item in items) {
        await txn.insert('order_items', {
          'order_id': orderId,
          'product_id': item['product_id'],
          'product_name': item['product_name'],
          'product_image': item['product_image'],
          'product_vendor': item['product_vendor'],
          'product_price': item['product_price'],
          'quantity': item['quantity'],
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    final db = await database;
    return await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    final db = await database;
    return await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> updateOrderStatus(
      String orderId, String status, DateTime? deliveredAt) async {
    final db = await database;
    final data = <String, dynamic>{'status': status};
    if (deliveredAt != null) {
      data['delivered_at'] = deliveredAt.toIso8601String();
    }
    await db.update('orders', data, where: 'id = ?', whereArgs: [orderId]);
  }

  // ─── Seed Data ────────────────────────────────────────────

  static final List<Category> _seedCategories = [
    const Category(
      id: 'electronics',
      name: 'Electronics',
      icon: Icons.devices,
      imageUrl:
          'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400',
    ),
    const Category(
      id: 'fashion',
      name: 'Fashion',
      icon: Icons.checkroom,
      imageUrl:
          'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400',
    ),
    const Category(
      id: 'home',
      name: 'Home & Living',
      icon: Icons.home,
      imageUrl:
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
    ),
    const Category(
      id: 'sports',
      name: 'Sports',
      icon: Icons.sports_basketball,
      imageUrl:
          'https://images.unsplash.com/photo-1461896836934-bd45ba8c3e1b?w=400',
    ),
    const Category(
      id: 'beauty',
      name: 'Beauty',
      icon: Icons.face,
      imageUrl:
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400',
    ),
    const Category(
      id: 'books',
      name: 'Books',
      icon: Icons.menu_book,
      imageUrl:
          'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400',
    ),
    const Category(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_basket,
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
    ),
    const Category(
      id: 'toys',
      name: 'Toys & Games',
      icon: Icons.toys,
      imageUrl:
          'https://images.unsplash.com/photo-1558060370-d644479cb6f7?w=400',
    ),
  ];

  static final List<Product> _seedProducts = [
    const Product(
      id: 'e1',
      name: 'Samsung Galaxy S24 Ultra',
      description:
          'Experience the pinnacle of mobile technology with the Samsung Galaxy S24 Ultra. Featuring a stunning 6.8" Dynamic AMOLED 2X display, powerful Snapdragon 8 Gen 3 processor, and an incredible 200MP camera system.',
      price: 389990.00,
      originalPrice: 429990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400',
      imageUrls: [
        'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400',
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
      ],
      categoryId: 'electronics',
      rating: 4.8,
      reviewCount: 1256,
      vendor: 'Samsung Official',
      specifications: {
        'Display': '6.8" Dynamic AMOLED 2X',
        'Processor': 'Snapdragon 8 Gen 3',
        'RAM': '12GB',
        'Storage': '256GB',
        'Battery': '5000mAh',
        'Camera': '200MP + 12MP + 50MP + 10MP',
      },
    ),
    const Product(
      id: 'e2',
      name: 'Apple MacBook Air M3',
      description:
          'Supercharged by the M3 chip, MacBook Air delivers exceptional performance in an impossibly thin design. Up to 18 hours of battery life and a brilliant Liquid Retina display.',
      price: 524990.00,
      originalPrice: 574990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
      categoryId: 'electronics',
      rating: 4.9,
      reviewCount: 892,
      vendor: 'Apple Store',
      specifications: {
        'Chip': 'Apple M3',
        'Display': '13.6" Liquid Retina',
        'RAM': '8GB Unified',
        'Storage': '256GB SSD',
        'Battery': 'Up to 18 hours',
      },
    ),
    const Product(
      id: 'e3',
      name: 'Sony WH-1000XM5 Headphones',
      description:
          'Industry-leading noise cancellation with Auto NC Optimizer. Crystal clear hands-free calling. Up to 30 hours of battery life with quick charging.',
      price: 89990.00,
      originalPrice: 109990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
      imageUrls: [
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400',
      ],
      categoryId: 'electronics',
      rating: 4.7,
      reviewCount: 2341,
      vendor: 'Sony Lanka',
      specifications: {
        'Type': 'Over-ear',
        'Noise Cancellation': 'Active (Auto NC Optimizer)',
        'Battery': '30 hours',
        'Driver': '30mm',
        'Weight': '250g',
      },
    ),
    const Product(
      id: 'e4',
      name: 'iPad Air 11" M2',
      description:
          'The iPad Air with M2 chip delivers powerful performance in a thin, portable design. Features an 11-inch Liquid Retina display and supports Apple Pencil Pro.',
      price: 249990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
      categoryId: 'electronics',
      rating: 4.6,
      reviewCount: 567,
      vendor: 'Apple Store',
    ),
    const Product(
      id: 'e5',
      name: 'JBL Charge 5 Speaker',
      description:
          'Portable Bluetooth speaker with powerful JBL Pro Sound, bold design, and IP67 waterproof and dustproof rating.',
      price: 34990.00,
      originalPrice: 42990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
      categoryId: 'electronics',
      rating: 4.5,
      reviewCount: 1890,
      vendor: 'JBL Official',
    ),
    const Product(
      id: 'f1',
      name: 'Nike Air Max 270 Running Shoes',
      description:
          'Nike Air Max 270 delivers visible cushioning under every step. Features Nike\'s biggest heel Air unit yet for a super-soft ride.',
      price: 24990.00,
      originalPrice: 29990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      imageUrls: [
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400',
      ],
      categoryId: 'fashion',
      rating: 4.6,
      reviewCount: 3456,
      vendor: 'Nike Store',
    ),
    const Product(
      id: 'f2',
      name: 'Levi\'s 501 Original Jeans',
      description:
          'The iconic straight fit with original riveted construction. Sits at the waist, regular through the thigh, with a straight leg.',
      price: 14990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
      categoryId: 'fashion',
      rating: 4.4,
      reviewCount: 1234,
      vendor: 'Levi\'s Official',
    ),
    const Product(
      id: 'f3',
      name: 'Ray-Ban Aviator Sunglasses',
      description:
          'The original Ray-Ban Aviator Classic. Gold metal frame with green G-15 lenses. Iconic design.',
      price: 29990.00,
      originalPrice: 34990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400',
      categoryId: 'fashion',
      rating: 4.7,
      reviewCount: 876,
      vendor: 'Ray-Ban Store',
    ),
    const Product(
      id: 'f4',
      name: 'Casio G-Shock GA-2100',
      description:
          'Thin, compact G-SHOCK with a carbon core guard structure. Shock resistance, 200m water resistance, world time.',
      price: 19990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      categoryId: 'fashion',
      rating: 4.8,
      reviewCount: 2100,
      vendor: 'Casio Lanka',
    ),
    const Product(
      id: 'h1',
      name: 'Dyson V15 Detect Vacuum',
      description:
          'Dyson\'s most powerful, intelligent cordless vacuum. Laser reveals microscopic dust. Piezo sensor counts and sizes particles.',
      price: 189990.00,
      originalPrice: 219990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400',
      categoryId: 'home',
      rating: 4.7,
      reviewCount: 456,
      vendor: 'Dyson Lanka',
    ),
    const Product(
      id: 'h2',
      name: 'Nespresso Vertuo Coffee Machine',
      description:
          'Brew barista-quality coffee at home. Centrifusion technology extracts rich crema-topped coffee. Makes 5 cup sizes.',
      price: 54990.00,
      originalPrice: 64990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=400',
      categoryId: 'home',
      rating: 4.5,
      reviewCount: 789,
      vendor: 'Nespresso',
    ),
    const Product(
      id: 'h3',
      name: 'Luxury Cotton Bedsheet Set',
      description:
          '800 thread count Egyptian cotton bedsheet set. Includes fitted sheet, flat sheet, and 2 pillowcases.',
      price: 12990.00,
      originalPrice: 16990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
      categoryId: 'home',
      rating: 4.3,
      reviewCount: 567,
      vendor: 'HomeComfort',
    ),
    const Product(
      id: 's1',
      name: 'Yoga Mat Premium 6mm',
      description:
          'Non-slip premium yoga mat with alignment lines. Made from eco-friendly TPE material.',
      price: 4990.00,
      originalPrice: 6990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400',
      categoryId: 'sports',
      rating: 4.4,
      reviewCount: 890,
      vendor: 'FitGear',
    ),
    const Product(
      id: 's2',
      name: 'Adjustable Dumbbell Set 20kg',
      description:
          'Space-saving adjustable dumbbell set. Quick-change weight system from 2kg to 20kg.',
      price: 15990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
      categoryId: 'sports',
      rating: 4.6,
      reviewCount: 345,
      vendor: 'IronFit',
    ),
    const Product(
      id: 's3',
      name: 'Wilson Tennis Racket Pro',
      description:
          'Professional grade tennis racket with graphite frame. Ideal for intermediate to advanced players.',
      price: 34990.00,
      originalPrice: 39990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=400',
      categoryId: 'sports',
      rating: 4.5,
      reviewCount: 210,
      vendor: 'Wilson Sports',
    ),
    const Product(
      id: 'b1',
      name: 'The Ordinary Skincare Set',
      description:
          'Complete skincare routine set including Niacinamide, Hyaluronic Acid, and Natural Moisturizing Factors. Ideal for all skin types.',
      price: 7990.00,
      originalPrice: 9990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400',
      categoryId: 'beauty',
      rating: 4.7,
      reviewCount: 3456,
      vendor: 'Beauty Hub',
    ),
    const Product(
      id: 'b2',
      name: 'MAC Lipstick Ruby Woo',
      description:
          'The iconic matte red lipstick. Ruby Woo is a vivid blue-red that looks stunning on every skin tone.',
      price: 6490.00,
      imageUrl:
          'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400',
      categoryId: 'beauty',
      rating: 4.8,
      reviewCount: 5678,
      vendor: 'MAC Cosmetics',
    ),
    const Product(
      id: 'b3',
      name: 'Dove Body Wash Collection',
      description:
          'Nourishing body wash gift set with 3 variants. Gentle cleansing with NutriumMoisture technology.',
      price: 3490.00,
      originalPrice: 4490.00,
      imageUrl:
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400',
      categoryId: 'beauty',
      rating: 4.3,
      reviewCount: 1200,
      vendor: 'Dove Lanka',
    ),
    const Product(
      id: 'bk1',
      name: 'Atomic Habits by James Clear',
      description:
          'An Easy & Proven Way to Build Good Habits & Break Bad Ones. One of the most impactful books on personal development.',
      price: 2990.00,
      originalPrice: 3990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
      categoryId: 'books',
      rating: 4.9,
      reviewCount: 8901,
      vendor: 'Book House',
    ),
    const Product(
      id: 'bk2',
      name: 'Rich Dad Poor Dad',
      description:
          'What the Rich Teach Their Kids About Money That the Poor and Middle Class Do Not! A classic on financial literacy.',
      price: 2490.00,
      imageUrl:
          'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
      categoryId: 'books',
      rating: 4.7,
      reviewCount: 6543,
      vendor: 'Book House',
    ),
    const Product(
      id: 'g1',
      name: 'Ceylon Tea Premium Collection',
      description:
          'Premium collection of authentic Ceylon teas. Includes black tea, green tea, and herbal infusions from Sri Lankan estates.',
      price: 1990.00,
      originalPrice: 2490.00,
      imageUrl:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
      categoryId: 'groceries',
      rating: 4.8,
      reviewCount: 2345,
      vendor: 'Ceylon Tea Co.',
    ),
    const Product(
      id: 'g2',
      name: 'Organic Spice Gift Box',
      description:
          'Collection of 12 organic Sri Lankan spices including cinnamon, cardamom, cloves, pepper, turmeric and more.',
      price: 3490.00,
      imageUrl:
          'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400',
      categoryId: 'groceries',
      rating: 4.6,
      reviewCount: 876,
      vendor: 'Spice Island',
    ),
    const Product(
      id: 't1',
      name: 'LEGO Creator 3-in-1 Set',
      description:
          'Build 3 different models with one set! Over 500 pieces for creative building. Suitable for ages 8+.',
      price: 12990.00,
      originalPrice: 15990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1587654780291-39c9404d7dd0?w=400',
      categoryId: 'toys',
      rating: 4.8,
      reviewCount: 1567,
      vendor: 'Toy World',
    ),
    const Product(
      id: 't2',
      name: 'Board Game Collection Box',
      description:
          'Family board game collection including Chess, Checkers, Ludo, and Snakes & Ladders. High quality wooden pieces.',
      price: 4990.00,
      imageUrl:
          'https://images.unsplash.com/photo-1611371805429-8b5c1b2c34ba?w=400',
      categoryId: 'toys',
      rating: 4.5,
      reviewCount: 432,
      vendor: 'Game Zone',
    ),
  ];
}

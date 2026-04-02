import 'package:flutter/foundation.dart' hide Category;
import '../models/product.dart';
import '../models/category.dart';
import '../services/database_helper.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _allProducts = [];
  List<Category> _categories = [];
  List<Product> _searchResults = [];
  String _searchQuery = '';
  bool _isLoading = true;

  List<Product> get allProducts => _allProducts;
  List<Category> get categories => _categories;
  List<Product> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<Product> get featuredProducts =>
      _allProducts.where((p) => p.rating >= 4.7).toList();

  List<Product> get dealsOfTheDay =>
      _allProducts.where((p) => p.originalPrice != null).toList();

  final _db = DatabaseHelper.instance;

  ProductProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    _allProducts = await _db.getAllProducts();
    _categories = await _db.getAllCategories();

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    return await _db.getProductsByCategory(categoryId);
  }

  List<Product> getProductsByCategorySync(String categoryId) {
    return _allProducts.where((p) => p.categoryId == categoryId).toList();
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = await _db.searchProducts(query);
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

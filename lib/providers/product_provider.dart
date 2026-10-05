import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/local_storage_service.dart';
import '../data/product_data.dart';

/// Product provider managing menu items, category filters, search queries, and admin CRUD operations.
class ProductProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService.instance;

  List<Product> _products = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  List<Product> get allProducts => _products;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  List<String> get categories => ProductData.categories;

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = (await _storage.getProducts()).toList();
    } catch (_) {
      _products = ProductData.products.toList();
    }
    _isLoading = false;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesCat =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  List<Product> get popularProducts {
    return _products.where((p) => p.available).take(6).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _storage.saveProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _storage.saveProduct(product);
    await loadProducts();
  }

  Future<void> toggleAvailability(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final updated = _products[index].copyWith(available: !_products[index].available);
      await _storage.saveProduct(updated);
      await loadProducts();
    }
  }

  Future<void> deleteProduct(String productId) async {
    await _storage.deleteProduct(productId);
    await loadProducts();
  }

  Product? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

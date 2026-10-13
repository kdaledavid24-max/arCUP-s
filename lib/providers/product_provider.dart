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
    // Synchronously seed in-memory list from cache or catalog to prevent empty-list flash on startup
    if (_storage.cachedProducts.isNotEmpty) {
      _products = _storage.cachedProducts.toList();
    } else {
      _products = ProductData.products.toList();
    }
    loadProducts();
  }

  /// Loads products from persistent storage and falls back safely to default catalog if empty.
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final loaded = await _storage.getProducts();
      if (loaded.isNotEmpty) {
        _products = loaded.toList();
      } else if (_products.isEmpty) {
        _products = ProductData.products.toList();
      }
    } catch (_) {
      if (_products.isEmpty) {
        _products = ProductData.products.toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters products based on selected category and search query.
  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesCat = isProductInCategory(p, _selectedCategory);
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  /// Robust category comparison accommodating case, whitespace, aliases, and special flags.
  static bool isProductInCategory(Product product, String category) {
    final cat = category.trim().toLowerCase();
    if (cat == 'all' || cat.isEmpty) return true;

    final pCat = product.category.trim().toLowerCase();

    // Special Day Specials category matches products with special flag or special in category name
    if (cat == 'special day specials' || cat == 'special day' || cat == 'specials') {
      return product.isSpecial || pCat.contains('special');
    }

    // Direct case-insensitive match
    if (pCat == cat) return true;

    // Frappe and Frappe Series aliases
    final isFrappeP = pCat == 'frappe' || pCat == 'frappe series';
    final isFrappeCat = cat == 'frappe' || cat == 'frappe series';
    if (isFrappeP && isFrappeCat) return true;

    // Coffee & Espresso aliases
    final isCoffeeP = pCat.contains('coffee') || pCat.contains('espresso');
    final isCoffeeCat = cat.contains('coffee') || cat.contains('espresso');
    if (isCoffeeP && isCoffeeCat) return true;

    // Salad
    if (cat.contains('salad') && pCat.contains('salad')) return true;

    // Pasta
    if (cat.contains('pasta') && pCat.contains('pasta')) return true;

    return false;
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

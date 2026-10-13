import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arcups_app/services/local_storage_service.dart';
import 'package:arcups_app/providers/product_provider.dart';
import 'package:arcups_app/data/product_data.dart';
import 'package:arcups_app/models/product.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalStorageService.instance.resetForTesting();
  });

  group('Product Persistence & Reopen Tests', () {
    test('Test 1: App launch 1 loads all default products', () async {
      final storage = LocalStorageService.instance;
      await storage.ensureReady();

      final products = await storage.getProducts();
      expect(products.isNotEmpty, true);
      expect(products.length, ProductData.products.length);

      final provider = ProductProvider();
      await provider.loadProducts();
      expect(provider.allProducts.length, ProductData.products.length);
    });

    test('Test 2: App simulated restart (memory wiped, reopened with seeded storage) does NOT deadlock or lose products', () async {
      // First session: launches app and writes default catalog to persistent storage
      final storage = LocalStorageService.instance;
      await storage.ensureReady();
      final firstLoad = await storage.getProducts();
      expect(firstLoad.isNotEmpty, true);

      // Verify SharedPreferences has persisted data
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('fo_seeded_v1'), true);
      expect(prefs.getString('fo_products'), isNotNull);

      // SIMULATE APP CLOSE & RESTART:
      // Memory wiped, static instances reinitialized, persistent disk storage remains intact
      storage.resetForTesting();

      // Second session (reopening app): LocalStorageService.ensureReady runs when isSeeded is true
      // Previously, this branch deadlocked because getProducts called ensureReady recursively!
      await storage.ensureReady();
      final reopenedProducts = await storage.getProducts();

      expect(reopenedProducts.isNotEmpty, true, reason: 'Products must not disappear after app is reopened');
      expect(reopenedProducts.length, firstLoad.length);

      final reopenedProvider = ProductProvider();
      await reopenedProvider.loadProducts();
      expect(reopenedProvider.allProducts.isNotEmpty, true);
      expect(reopenedProvider.filteredProducts.isNotEmpty, true);
    });

    test('Test 3: Admin product modifications survive app restarts', () async {
      final storage = LocalStorageService.instance;
      await storage.ensureReady();

      // Add a custom product in session 1
      const newProduct = Product(
        id: 'custom_001',
        name: 'Caramel Hazelnut Cold Brew',
        category: 'Coffee & Espresso',
        description: 'Slow-steeped cold brew with roasted hazelnut syrup',
        price: 180.0,
        image: 'assets/images/drinks/americano.jpg',
      );

      final provider = ProductProvider();
      await provider.addProduct(newProduct);

      // Verify it exists in current session
      expect(provider.allProducts.any((p) => p.id == 'custom_001'), true);

      // SIMULATE RESTART: wipe memory, re-read from storage
      storage.resetForTesting();
      await storage.ensureReady();

      final reloaded = await storage.getProducts();
      expect(reloaded.any((p) => p.id == 'custom_001'), true, reason: 'Admin added product should persist after restart');

      final newProvider = ProductProvider();
      await newProvider.loadProducts();
      expect(newProvider.allProducts.any((p) => p.id == 'custom_001'), true);
    });
  });

  group('Category Filtering Verification Tests', () {
    late ProductProvider provider;

    setUp(() async {
      final storage = LocalStorageService.instance;
      await storage.ensureReady();
      provider = ProductProvider();
      await provider.loadProducts();
    });

    test('Category "All" displays all products', () {
      provider.setCategory('All');
      expect(provider.filteredProducts.length, provider.allProducts.length);
    });

    test('Category "Special Day Specials" displays celebration and special-tagged items', () {
      provider.setCategory('Special Day Specials');
      final specials = provider.filteredProducts;
      expect(specials.isNotEmpty, true);
      for (final p in specials) {
        expect(p.isSpecial || p.category == 'Special Day Specials', true);
      }
      expect(specials.any((p) => p.name.contains('Strawberry Velvet')), true);
    });

    test('Category "Coffee & Espresso" displays only coffee products', () {
      provider.setCategory('Coffee & Espresso');
      final coffees = provider.filteredProducts;
      expect(coffees.isNotEmpty, true);
      for (final p in coffees) {
        expect(p.category.toLowerCase().contains('coffee') || p.category.toLowerCase().contains('espresso'), true);
      }
    });

    test('Category "Frappe" matches frappe items even if stored with "Frappe Series"', () {
      provider.setCategory('Frappe');
      final frappes = provider.filteredProducts;
      expect(frappes.isNotEmpty, true);
      expect(frappes.length >= 10, true);
      for (final p in frappes) {
        final cat = p.category.toLowerCase();
        expect(cat == 'frappe' || cat == 'frappe series', true);
      }
    });

    test('Category "Salad" displays salad items', () {
      provider.setCategory('Salad');
      final salads = provider.filteredProducts;
      expect(salads.isNotEmpty, true);
      for (final p in salads) {
        expect(p.category.toLowerCase().contains('salad'), true);
      }
    });

    test('Category "Pasta" displays pasta items', () {
      provider.setCategory('Pasta');
      final pastas = provider.filteredProducts;
      expect(pastas.isNotEmpty, true);
      for (final p in pastas) {
        expect(p.category.toLowerCase().contains('pasta'), true);
      }
    });

    test('Case-insensitivity and whitespace resilience in categories', () {
      provider.setCategory('  coffee & espresso  ');
      expect(provider.filteredProducts.isNotEmpty, true);

      provider.setCategory('frappe');
      expect(provider.filteredProducts.isNotEmpty, true);

      provider.setCategory('ALL');
      expect(provider.filteredProducts.length, provider.allProducts.length);
    });
  });
}

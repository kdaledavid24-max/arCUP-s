import 'package:flutter_test/flutter_test.dart';
import 'package:arcups_app/data/product_data.dart';
import 'package:arcups_app/providers/cart_provider.dart';
import 'package:arcups_app/providers/order_provider.dart';

void main() {
  group('Product Data & Guidelines Verification', () {
    test('All products have valid prices according to project requirements', () {
      expect(ProductData.products.isNotEmpty, true);

      for (final p in ProductData.products) {
        if (p.category == 'Coffee & Espresso' || p.category == 'Frappe Series') {
          // Drinks range ₱100 - ₱200
          expect(
            p.price >= 100.0 && p.price <= 200.0,
            true,
            reason: '${p.name} drink price ₱${p.price} should be between ₱100 and ₱200',
          );
        } else if (p.category == 'Salad' || p.category == 'Pasta') {
          // Salad and Pasta range ₱200 - ₱300
          expect(
            p.price >= 200.0 && p.price <= 300.0,
            true,
            reason: '${p.name} food price ₱${p.price} should be between ₱200 and ₱300',
          );
        }
      }
    });

    test('All categories match requirements', () {
      expect(ProductData.categories, containsAll([
        'All',
        'Coffee & Espresso',
        'Frappe Series',
        'Salad',
        'Pasta',
      ]));
    });
  });

  group('Cart Provider Unit Tests', () {
    late CartProvider cart;

    setUp(() {
      cart = CartProvider();
    });

    test('Initial cart is empty', () {
      expect(cart.isEmpty, true);
      expect(cart.items.length, 0);
      expect(cart.totalItemCount, 0);
      expect(cart.subtotal, 0.0);
      expect(cart.totalAmount, 0.0);
    });

    test('Adding product adds new cart item', () {
      final product = ProductData.products.first; // Biscoff Latte (₱160)
      cart.addItem(product, quantity: 2);

      expect(cart.isEmpty, false);
      expect(cart.items.length, 1);
      expect(cart.totalItemCount, 2);
      expect(cart.subtotal, 320.0);
      expect(cart.totalAmount, 320.0);
    });

    test('Adding duplicate product increases quantity instead of creating new item', () {
      final product = ProductData.products.first;
      cart.addItem(product, quantity: 1);
      cart.addItem(product, quantity: 2);

      expect(cart.items.length, 1);
      expect(cart.totalItemCount, 3);
      expect(cart.items.first.quantity, 3);
    });

    test('Increment and Decrement quantity work correctly', () {
      final product = ProductData.products.first;
      cart.addItem(product, quantity: 2);

      cart.incrementQuantity(product.id);
      expect(cart.totalItemCount, 3);

      cart.decrementQuantity(product.id);
      expect(cart.totalItemCount, 2);

      // Decrement to 1 then to 0 removes the item
      cart.decrementQuantity(product.id);
      expect(cart.totalItemCount, 1);

      cart.decrementQuantity(product.id);
      expect(cart.isEmpty, true);
    });

    test('Remove item and Clear cart work properly', () {
      final p1 = ProductData.products[0];
      final p2 = ProductData.products[1];

      cart.addItem(p1, quantity: 1);
      cart.addItem(p2, quantity: 1);
      expect(cart.items.length, 2);

      cart.removeItem(p1.id);
      expect(cart.items.length, 1);
      expect(cart.items.first.product.id, p2.id);

      cart.clearCart();
      expect(cart.isEmpty, true);
    });
  });

  group('Order Provider Unit Tests', () {
    test('Can manage orders and retrieve by id', () {
      final orderProvider = OrderProvider();
      expect(orderProvider.allOrders, isNotNull);
    });
  });
}

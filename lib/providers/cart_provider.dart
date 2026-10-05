import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// Provider that manages cart state, item quantities, and price calculations.
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  double _deliveryFee = 0.0; // ₱0 for dine-in or take-out counter pickup

  List<CartItem> get items => List.unmodifiable(_items);

  /// Total count of individual items (summing quantities)
  int get totalItemCount {
    int count = 0;
    for (final item in _items) {
      count += item.quantity;
    }
    return count;
  }

  /// Calculates the subtotal of all items in cart
  double get subtotal {
    double total = 0.0;
    for (final item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  /// Delivery/service fee
  double get deliveryFee => _deliveryFee;

  /// Sets delivery fee (e.g. ₱45 for delivery, ₱0 for dine-in/take-out)
  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    notifyListeners();
  }

  /// Grand Total = subtotal + deliveryFee
  double get totalAmount => subtotal + _deliveryFee;

  /// Whether the cart is currently empty
  bool get isEmpty => _items.isEmpty;

  /// Adds a product to the cart. If it already exists, increases quantity.
  void addItem(Product product, {int quantity = 1}) {
    if (quantity <= 0) return;

    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  /// Increases quantity of an existing cart item by 1
  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  /// Decreases quantity of an existing cart item. If quantity reaches 0, removes it.
  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Completely removes an item from cart
  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Empties the cart after successful checkout
  void clearCart() {
    _items.clear();
    _deliveryFee = 0.0;
    notifyListeners();
  }
}

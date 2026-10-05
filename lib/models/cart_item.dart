import 'product.dart';

/// Model representing an individual item placed inside the shopping cart.
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Calculates the total cost for this item (product price * quantity).
  double get totalPrice => product.price * quantity;
}

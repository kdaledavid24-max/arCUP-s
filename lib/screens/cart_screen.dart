import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_item_card.dart';

/// Shopping Cart Screen displaying items, quantities, subtotal, and checkout entry.
class CartScreen extends StatelessWidget {
  final VoidCallback? onBrowseMenu;

  const CartScreen({super.key, this.onBrowseMenu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                tooltip: 'Clear Cart',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.cardSurface,
                      title: const Text('Clear Cart', style: TextStyle(color: AppTheme.textWhite)),
                      content: const Text(
                        'Are you sure you want to remove all items from your cart?',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            cart.clearCart();
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 72,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add delicious coffee, frappes, salad or pasta!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.restaurant_menu_rounded),
                      label: const Text('Browse Menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (onBrowseMenu != null) {
                          onBrowseMenu!();
                        } else {
                          Navigator.pushNamed(context, '/menu');
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          final freeDeliveryDiff = 500.0 - cart.subtotal;

          return Column(
            children: [
              // Free Delivery Promo Banner
              if (freeDeliveryDiff > 0)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_rounded, color: AppTheme.goldAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Add ₱${freeDeliveryDiff.toStringAsFixed(2)} more for FREE Delivery!',
                          style: const TextStyle(color: AppTheme.goldAccent, fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'You qualify for FREE Delivery!',
                        style: TextStyle(color: AppTheme.successGreen, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

              // Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return CartItemCard(item: item);
                  },
                ),
              ),

              // Summary and Checkout Action
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: const Border(top: BorderSide(color: AppTheme.cardBorder)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
                          Text(
                            '₱${cart.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textWhite),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Est. Delivery', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
                          Text(
                            cart.subtotal >= 500 ? 'FREE' : '₱40.00',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cart.subtotal >= 500 ? AppTheme.successGreen : AppTheme.textWhite,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppTheme.cardBorder),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Grand Total', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                          Text(
                            '₱${(cart.subtotal + (cart.subtotal >= 500 ? 0.0 : 40.0)).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.goldAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.goldAccent,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'PROCEED TO CHECKOUT (${cart.totalItemCount} ITEMS)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'order_confirmation_screen.dart';

/// Comprehensive checkout screen with delivery/pickup options, customer inputs, and payment methods.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  String _orderType = 'Delivery'; // 'Delivery' or 'Pickup'
  String _paymentMethod = 'Cash'; // 'Cash', 'GCash', 'Card'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _calculateDeliveryFee(double subtotal) {
    if (_orderType == 'Pickup') return 0.0;
    if (subtotal >= 500) return 0.0; // Free delivery over ₱500
    return 40.0;
  }

  Future<void> _confirmOrder(CartProvider cart) async {
    if (!_formKey.currentState!.validate()) return;

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final orderProv = context.read<OrderProvider>();

    final subtotal = cart.subtotal;
    final deliveryFee = _calculateDeliveryFee(subtotal);
    final totalAmount = subtotal + deliveryFee;

    final items = cart.items
        .map(
          (i) => OrderItemModel(
            productId: i.product.id,
            productName: i.product.name,
            price: i.product.price,
            quantity: i.quantity,
            image: i.product.image,
          ),
        )
        .toList();

    final order = await orderProv.placeOrder(
      userId: auth.currentUser?.id ?? 0,
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      deliveryAddress: _orderType == 'Delivery' ? _addressController.text.trim() : 'Store Pickup',
      orderType: _orderType,
      paymentMethod: _paymentMethod,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      items: items,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    cart.clearCart();

    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(order: order),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.subtotal;
    final deliveryFee = _calculateDeliveryFee(subtotal);
    final grandTotal = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_shopping_cart_outlined, size: 60, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  const Text('No items to checkout!', style: TextStyle(color: AppTheme.textWhite, fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldAccent, foregroundColor: Colors.black),
                    child: const Text('Return to Cart'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Order Type Selector (Delivery vs Pickup)
                    const Text('Service Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeTile(
                            title: 'Delivery',
                            icon: Icons.delivery_dining_rounded,
                            subtitle: subtotal >= 500 ? 'FREE (Orders > ₱500)' : '₱40.00 fee',
                            isSelected: _orderType == 'Delivery',
                            onTap: () => setState(() => _orderType = 'Delivery'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTypeTile(
                            title: 'Store Pickup',
                            icon: Icons.storefront_rounded,
                            subtitle: 'Ready in 15-20 min',
                            isSelected: _orderType == 'Pickup',
                            onTap: () => setState(() => _orderType = 'Pickup'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 2: Contact Information
                    const Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AppTheme.textWhite),
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.goldAccent),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppTheme.textWhite),
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.goldAccent),
                        hintText: '0917 123 4567',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter phone number' : null,
                    ),
                    if (_orderType == 'Delivery') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        style: const TextStyle(color: AppTheme.textWhite),
                        decoration: const InputDecoration(
                          labelText: 'Delivery Address *',
                          prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.goldAccent),
                          hintText: 'House #, Street, Barangay, City',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter delivery address' : null,
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      style: const TextStyle(color: AppTheme.textWhite),
                      decoration: const InputDecoration(
                        labelText: 'Order Notes (Optional)',
                        prefixIcon: Icon(Icons.note_alt_outlined, color: AppTheme.goldAccent),
                        hintText: 'Special requests, landmark, etc.',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 3: Payment Method
                    const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPaymentChip('Cash', Icons.money_rounded),
                        const SizedBox(width: 8),
                        _buildPaymentChip('GCash', Icons.qr_code_2_rounded),
                        const SizedBox(width: 8),
                        _buildPaymentChip('Card', Icons.credit_card_rounded),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 4: Order Summary
                    const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Column(
                        children: [
                          ...cart.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.quantity}x ${item.product.name}',
                                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text(
                                    '₱${item.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(color: AppTheme.cardBorder, height: 18),
                          _buildCostRow('Subtotal', '₱${subtotal.toStringAsFixed(2)}'),
                          _buildCostRow('Delivery Fee', deliveryFee == 0 ? 'FREE' : '₱${deliveryFee.toStringAsFixed(2)}'),
                          const Divider(color: AppTheme.cardBorder, height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                              Text(
                                '₱${grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Place Order Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _confirmOrder(cart),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : Text(
                              'PLACE ORDER • ₱${grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTypeTile({
    required String title,
    required IconData icon,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.goldAccent.withValues(alpha: 0.15) : AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.goldAccent : AppTheme.cardBorder, width: isSelected ? 1.5 : 1.0),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppTheme.goldAccent : AppTheme.textMuted, size: 28),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(color: isSelected ? AppTheme.goldAccent : AppTheme.textWhite, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentChip(String method, IconData icon) {
    final isSelected = _paymentMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _paymentMethod = method),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.goldAccent : AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppTheme.goldAccent : AppTheme.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.black : AppTheme.textWhite, size: 18),
              const SizedBox(width: 6),
              Text(
                method,
                style: TextStyle(
                  color: isSelected ? Colors.black : AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

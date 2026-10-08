import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/interactive_delivery_map.dart';
import 'order_confirmation_screen.dart';

/// Checkout screen matching the exact design from the reference screenshot:
/// - Fulfillment method card (Dine In, Pick Up, Delivery)
/// - Customer Information card (Full Name, Phone Number, Delivery Address + Interactive Map, Promo Checkbox)
/// - Order Summary card (Items list, Subtotal, Voucher input + Apply, Total)
/// - Payment card (GCash, Cash)
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
  late TextEditingController _voucherController;

  String _orderType = 'Delivery'; // 'Dine In', 'Pick Up', 'Delivery'
  String _paymentMethod = 'GCash'; // 'GCash', 'Cash'
  bool _isSubmitting = false;
  bool _optInMarketing = false;

  double _discountAmount = 0.0;
  String? _appliedVoucher;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(
      text: (user?.address != null && user!.address!.trim().isNotEmpty)
          ? user.address!
          : 'E-2K Marketing, 678 Ronquillo Street, Quiapo, Manila, 1001 Metro Manila, Philippines',
    );
    _voucherController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  double _calculateDeliveryFee(double subtotal) {
    if (_orderType != 'Delivery') return 0.0;
    if (subtotal >= 500) return 0.0; // Free delivery over ₱500
    return 40.0;
  }

  void _applyVoucher(double subtotal) {
    final code = _voucherController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    if (code == 'AMICOFFEE' || code == 'DISCOUNT10' || code == 'COFFEE') {
      setState(() {
        _discountAmount = subtotal * 0.10; // 10% discount
        _appliedVoucher = code;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code $code applied (-10%)!'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid promo code. Try: AMICOFFEE'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
    final totalAmount = (subtotal - _discountAmount + deliveryFee).clamp(0.0, double.infinity);

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
      deliveryAddress: _orderType == 'Delivery'
          ? _addressController.text.trim()
          : (_orderType == 'Dine In' ? 'Dine In Order' : 'Store Pickup'),
      orderType: _orderType,
      paymentMethod: _paymentMethod,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      items: items,
      notes: _appliedVoucher != null ? 'Voucher applied: $_appliedVoucher' : null,
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
    final grandTotal = (subtotal - _discountAmount + deliveryFee).clamp(0.0, double.infinity);

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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Return to Cart'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Fulfillment Method Selector
                    _buildSectionCard(
                      title: 'How would you like to receive your order?',
                      subtitle: 'Choose a fulfillment method.',
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildFulfillmentTile(
                              title: 'Dine In',
                              subtitle: 'Enjoy your meal at our restaurant',
                              icon: Icons.restaurant_rounded,
                              isSelected: _orderType == 'Dine In',
                              onTap: () => setState(() => _orderType = 'Dine In'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFulfillmentTile(
                              title: 'Pick Up',
                              subtitle: 'Order ahead and pick up at our location',
                              icon: Icons.inventory_2_rounded,
                              isSelected: _orderType == 'Pick Up',
                              onTap: () => setState(() => _orderType = 'Pick Up'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFulfillmentTile(
                              title: 'Delivery',
                              subtitle: 'Get your order delivered to your door',
                              icon: Icons.delivery_dining_rounded,
                              isSelected: _orderType == 'Delivery',
                              onTap: () => setState(() => _orderType = 'Delivery'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Customer Information
                    _buildSectionCard(
                      title: 'Customer Information',
                      subtitle: 'Please provide the following details',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name & Phone Number in a 2-column Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Full Name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Full Name'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _nameController,
                                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                                      decoration: _inputDecoration('Enter your name'),
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Phone Number (+63 prefix, 0/10 counter)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Phone Number'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                                      decoration: _inputDecoration(
                                        '9XXXXXXXXX',
                                        prefixText: '+63 ',
                                      ),
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone' : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Delivery Address & Map (Only if Delivery is selected)
                          if (_orderType == 'Delivery') ...[
                            const SizedBox(height: 14),
                            InteractiveDeliveryMap(controller: _addressController),
                          ],

                          const SizedBox(height: 14),

                          // Marketing / Updates Checkbox
                          InkWell(
                            onTap: () => setState(() => _optInMarketing = !_optInMarketing),
                            borderRadius: BorderRadius.circular(6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _optInMarketing,
                                    onChanged: (v) => setState(() => _optInMarketing = v ?? false),
                                    activeColor: AppTheme.goldAccent,
                                    checkColor: Colors.black,
                                    side: const BorderSide(color: Color(0xFF4A4A4A), width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Text me updates and offers from Am I Coffee?. Standard message rates apply, and you can opt out any time.',
                                    style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 11.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 3: Order Summary
                    _buildSectionCard(
                      title: 'Order Summary',
                      subtitle: 'Review your order before checkout',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Items list with underline dividers
                          ...cart.items.map(
                            (item) => Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.product.name} x${item.quantity}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '₱${item.totalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(color: Color(0xFF262626), height: 1),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Subtotal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal', style: TextStyle(color: Colors.white70, fontSize: 13.5)),
                              Text(
                                '₱${subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),

                          if (_orderType == 'Delivery') ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Delivery Fee', style: TextStyle(color: Colors.white70, fontSize: 13.5)),
                                Text(
                                  deliveryFee == 0 ? 'FREE' : '₱${deliveryFee.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ],

                          if (_discountAmount > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Discount ($_appliedVoucher)', style: const TextStyle(color: AppTheme.successGreen, fontSize: 13.5)),
                                Text(
                                  '-₱${_discountAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 14),

                          // Voucher Code Field + Apply Button
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 42,
                                  child: TextFormField(
                                    controller: _voucherController,
                                    textCapitalization: TextCapitalization.characters,
                                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                                    decoration: InputDecoration(
                                      hintText: 'ENTER CODE',
                                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 11.5, letterSpacing: 1),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      filled: true,
                                      fillColor: const Color(0xFF101927),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFF2C3847)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFF2C3847)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 42,
                                child: OutlinedButton(
                                  onPressed: () => _applyVoucher(subtotal),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Color(0xFF2C3847)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFF262626), height: 1),
                          const SizedBox(height: 14),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₱${grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 4: Payment
                    _buildSectionCard(
                      title: 'Payment',
                      subtitle: 'Choose how you would like to pay',
                      child: Row(
                        children: [
                          _buildPaymentOptionCard(
                            label: 'GCash',
                            icon: Icons.qr_code_2_rounded,
                            iconColor: const Color(0xFF007DFE),
                            isSelected: _paymentMethod == 'GCash',
                            onTap: () => setState(() => _paymentMethod = 'GCash'),
                          ),
                          const SizedBox(width: 14),
                          _buildPaymentOptionCard(
                            label: 'Cash',
                            icon: Icons.payments_outlined,
                            iconColor: Colors.black87,
                            isSelected: _paymentMethod == 'Cash',
                            onTap: () => setState(() => _paymentMethod = 'Cash'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Place Order Action Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _confirmOrder(cart),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                            )
                          : Text(
                              'PLACE ORDER • ₱${grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1.1,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  /// Wrapper container for each section card matching the dark rounded aesthetics
  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111722),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2838), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// Fulfillment Method Tile (Dine In, Pick Up, Delivery)
  Widget _buildFulfillmentTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF8F0) : const Color(0xFF141E2B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFEA580C) : const Color(0xFF223044),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFEA580C).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Selected Checkmark Badge (top right)
            if (isSelected)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFFEA580C),
                  size: 16,
                ),
              ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular Icon Background
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEA580C) : const Color(0xFF1E2838),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFFC2410C) : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.25,
                    color: isSelected ? const Color(0xFF7C2D12) : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// White Square Payment Option Card (GCash, Cash)
  Widget _buildPaymentOptionCard({
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.goldAccent : Colors.transparent,
            width: isSelected ? 3.0 : 0.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: iconColor),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: AppTheme.textWhite,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFF101927),
      counterStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF223044)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF223044)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
      ),
    );
  }
}

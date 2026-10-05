import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import 'order_details_screen.dart';

/// Screen displayed immediately following a successfully confirmed order.
class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Animated Success Icon Badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.successGreen.withValues(alpha: 0.15),
                  border: Border.all(color: AppTheme.successGreen, width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 54,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(height: 20),

              // Success Message
              const Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for ordering at Food Ordering',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 24),

              // Estimated Preparation Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.goldAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.timer_rounded, color: AppTheme.goldAccent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Time',
                          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.orderType == 'Delivery' ? '25 - 35 mins' : '15 - 20 mins',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Order Receipt Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Order Code', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.goldAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppTheme.cardBorder),
                    ),

                    _buildInfoRow('Customer Name', order.customerName),
                    const SizedBox(height: 8),
                    _buildInfoRow('Contact Number', order.customerPhone),
                    const SizedBox(height: 8),
                    _buildInfoRow('Order Type', order.orderType),
                    const SizedBox(height: 8),
                    _buildInfoRow('Payment Method', order.paymentMethod),
                    const SizedBox(height: 8),
                    _buildInfoRow('Status', order.orderStatus, isStatus: true),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: AppTheme.cardBorder),
                    ),

                    const Text(
                      'Items Ordered',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.quantity}x ${item.productName}',
                              style: const TextStyle(fontSize: 14, color: AppTheme.textWhite),
                            ),
                            Text(
                              '₱${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: AppTheme.cardBorder),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textWhite,
                          ),
                        ),
                        Text(
                          '₱${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerOrderDetailsScreen(orderId: order.id),
                    ),
                  );
                },
                icon: const Icon(Icons.track_changes_rounded),
                label: const Text('TRACK MY ORDER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                },
                icon: const Icon(Icons.home_rounded, color: AppTheme.textWhite),
                label: const Text('Back to Home', style: TextStyle(color: AppTheme.textWhite)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppTheme.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
        isStatus
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningOrange,
                  ),
                ),
              )
            : Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_tracker.dart';

class AdminOrderDetailsScreen extends StatelessWidget {
  final int orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final order = orderProv.getOrderById(orderId);

    if (order == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(
          child: Text('Order not found', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(order.orderNumber),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Tracker
            StatusTracker(
              currentStatus: order.orderStatus,
              orderType: order.orderType,
            ),
            const SizedBox(height: 20),

            // Admin Status Control Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Order Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textWhite),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusBtn(context, orderProv, 'Pending', Colors.amber),
                      _buildStatusBtn(context, orderProv, 'Preparing', Colors.lightBlue),
                      _buildStatusBtn(context, orderProv, order.orderType == 'Delivery' ? 'Out for Delivery' : 'Ready', Colors.cyan),
                      _buildStatusBtn(context, orderProv, 'Delivered', AppTheme.successGreen),
                      _buildStatusBtn(context, orderProv, 'Cancelled', Colors.redAccent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Customer Information Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textWhite),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Customer Name', order.customerName),
                  _buildDetailRow('Phone Number', order.customerPhone),
                  _buildDetailRow('Order Type', order.orderType),
                  _buildDetailRow('Delivery Address', order.deliveryAddress),
                  _buildDetailRow('Payment Method', '${order.paymentMethod} (${order.paymentStatus})'),
                  if (order.notes != null && order.notes!.isNotEmpty)
                    _buildDetailRow('Special Instructions', order.notes!),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ordered Items Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Items',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textWhite),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.imageBackdrop,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.image != null
                                    ? Image.asset(item.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood))
                                    : const Icon(Icons.fastfood),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textWhite,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '₱${item.price.toStringAsFixed(2)} × ${item.quantity}',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₱${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textWhite),
                            ),
                          ],
                        ),
                      )),
                  const Divider(color: AppTheme.cardBorder, height: 20),
                  _buildSummaryRow('Subtotal', '₱${order.subtotal.toStringAsFixed(2)}'),
                  _buildSummaryRow('Delivery Fee', '₱${order.deliveryFee.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _buildSummaryRow('Grand Total', '₱${order.totalAmount.toStringAsFixed(2)}', isBold: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBtn(BuildContext context, OrderProvider provider, String targetStatus, Color color) {
    return ElevatedButton(
      onPressed: () async {
        await provider.updateStatus(orderId, targetStatus);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order status updated to $targetStatus'),
              backgroundColor: color,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        elevation: 0,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(targetStatus, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? AppTheme.goldAccent : AppTheme.textMuted,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 15 : 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isBold ? AppTheme.goldAccent : AppTheme.textWhite,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

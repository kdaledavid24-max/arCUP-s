import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../models/order_model.dart';
import 'order_details_screen.dart';

/// Screen displaying the history of customer orders with real-time status chips and tracking.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return AppTheme.successGreen;
      case 'preparing':
      case 'ready':
      case 'out for delivery':
        return Colors.lightBlueAccent;
      case 'cancelled':
        return Colors.redAccent;
      case 'pending':
      default:
        return AppTheme.warningOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProv = context.watch<OrderProvider>();

    final user = auth.currentUser;
    final orders = user != null
        ? orderProv.getOrdersForUser(user.id)
        : orderProv.allOrders;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: RefreshIndicator(
        onRefresh: () => orderProv.loadOrders(),
        color: AppTheme.goldAccent,
        backgroundColor: AppTheme.cardSurface,
        child: orders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No orders placed yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your past orders will appear right here.',
                      style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldAccent,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Browse Menu'),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(context, order);
                },
              ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final statusColor = _getStatusColor(order.orderStatus);
    final formattedDate =
        '${order.createdAt.month}/${order.createdAt.day}/${order.createdAt.year} • ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerOrderDetailsScreen(orderId: order.id),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.goldAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_rounded, color: AppTheme.goldAccent, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      order.orderStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${order.items.length} items (${order.orderType})',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                order.items.map((i) => '${i.quantity}x ${i.productName}').join(', '),
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(color: AppTheme.cardBorder, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text(
                        '₱${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

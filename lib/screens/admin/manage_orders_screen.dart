import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import 'admin_order_details_screen.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final List<String> _filters = ['All', 'Pending', 'Preparing', 'Ready', 'Delivered', 'Cancelled'];
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final orders = _activeFilter == 'All'
        ? orderProv.allOrders
        : orderProv.allOrders
            .where((o) => o.orderStatus.toLowerCase() == _activeFilter.toLowerCase())
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Manage Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _activeFilter = filter);
                    },
                    selectedColor: AppTheme.goldAccent,
                    backgroundColor: AppTheme.cardSurface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : AppTheme.textWhite,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.goldAccent : AppTheme.cardBorder,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Orders List
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded, size: 54, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'No $_activeFilter orders found.',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminOrderDetailsScreen(orderId: order.id),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      order.orderNumber,
                                      style: const TextStyle(
                                        color: AppTheme.goldAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order.orderStatus).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _getStatusColor(order.orderStatus)),
                                      ),
                                      child: Text(
                                        order.orderStatus,
                                        style: TextStyle(
                                          color: _getStatusColor(order.orderStatus),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  order.customerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textWhite,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📞 ${order.customerPhone} • ${order.orderType}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📍 ${order.deliveryAddress}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Divider(color: AppTheme.cardBorder, height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${order.items.length} items (${order.paymentMethod})',
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                    ),
                                    Text(
                                      '₱${order.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textWhite,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

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
}

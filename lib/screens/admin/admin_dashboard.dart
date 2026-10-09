import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import 'manage_orders_screen.dart';
import 'manage_products_screen.dart';
import 'manage_users_screen.dart';
import 'sales_screen.dart';
import 'admin_order_details_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProv = context.watch<OrderProvider>();
    final prodProv = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_rounded, color: AppTheme.goldAccent),
            tooltip: 'Switch to Customer View',
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await orderProv.loadOrders();
          await prodProv.loadProducts();
        },
        color: AppTheme.goldAccent,
        backgroundColor: AppTheme.cardSurface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B2B44), Color(0xFF142034)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.goldAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.goldAccent),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.goldAccent, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${auth.currentUser?.name ?? "Administrator"}',
                            style: const TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Food Ordering Management System',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KPI Metric Cards
              const Text(
                'Key Metrics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMetricCard(
                    title: 'Total Revenue',
                    value: '₱${orderProv.totalRevenue.toStringAsFixed(2)}',
                    icon: Icons.payments_rounded,
                    color: AppTheme.successGreen,
                  ),
                  _buildMetricCard(
                    title: 'Total Orders',
                    value: '${orderProv.totalOrdersCount}',
                    icon: Icons.receipt_long_rounded,
                    color: AppTheme.goldAccent,
                  ),
                  _buildMetricCard(
                    title: 'Pending Orders',
                    value: '${orderProv.pendingOrdersCount}',
                    icon: Icons.pending_actions_rounded,
                    color: AppTheme.warningOrange,
                  ),
                  _buildMetricCard(
                    title: 'Total Products',
                    value: '${prodProv.allProducts.length}',
                    icon: Icons.fastfood_rounded,
                    color: Colors.lightBlueAccent,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Action Grid
              const Text(
                'Management Sections',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      context,
                      title: 'Manage Orders',
                      icon: Icons.list_alt_rounded,
                      subtitle: '${orderProv.activeOrdersCount} active',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      title: 'Menu Catalog',
                      icon: Icons.inventory_2_rounded,
                      subtitle: 'Edit products',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      context,
                      title: 'Sales Report',
                      icon: Icons.bar_chart_rounded,
                      subtitle: 'Analytics & Revenue',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SalesScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      title: 'User Accounts',
                      icon: Icons.people_alt_rounded,
                      subtitle: 'Customer directory',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Orders List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
                    ),
                    child: const Text('View All', style: TextStyle(color: AppTheme.goldAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (orderProv.allOrders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: const Center(
                    child: Text('No orders placed yet.', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderProv.allOrders.take(5).length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = orderProv.allOrders[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                          MaterialPageRoute(
                            builder: (_) => AdminOrderDetailsScreen(orderId: order.id),
                          ),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.darkBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: const Icon(Icons.receipt_rounded, color: AppTheme.goldAccent, size: 20),
                        ),
                        title: Text(
                          '${order.orderNumber} • ${order.customerName}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textWhite, fontSize: 14),
                        ),
                        subtitle: Text(
                          '${order.items.length} items • ₱${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                        trailing: Container(
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
                      ),
                    ),
                  );
                  },
                ),
            ],
          ),
        ),
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.goldAccent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textWhite,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

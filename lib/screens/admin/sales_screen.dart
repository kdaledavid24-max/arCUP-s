import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final prodProv = context.watch<ProductProvider>();

    final orders = orderProv.allOrders.where((o) => o.orderStatus != 'Cancelled').toList();
    final totalRevenue = orderProv.totalRevenue;
    final totalDelivered = orderProv.completedOrdersCount;

    // Calculate item sales breakdown
    final Map<String, int> productQuantities = {};
    final Map<String, double> productSales = {};

    for (final order in orders) {
      for (final item in order.items) {
        productQuantities[item.productName] = (productQuantities[item.productName] ?? 0) + item.quantity;
        productSales[item.productName] = (productSales[item.productName] ?? 0) + item.subtotal;
      }
    }

    final sortedItems = productQuantities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Sales & Revenue'),
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
            // Revenue Summary Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B2B44), Color(0xFF142034)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Net Sales', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    '₱${totalRevenue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniStat('Orders Placed', '${orders.length}'),
                      const SizedBox(width: 24),
                      _buildMiniStat('Fulfilled', '$totalDelivered'),
                      const SizedBox(width: 24),
                      _buildMiniStat('Catalog Items', '${prodProv.allProducts.length}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top Selling Items
            const Text(
              'Item Performance',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textWhite),
            ),
            const SizedBox(height: 12),
            if (sortedItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Center(
                  child: Text('No sales recorded yet.', style: TextStyle(color: AppTheme.textMuted)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = sortedItems[index];
                  final name = entry.key;
                  final qty = entry.value;
                  final sales = productSales[name] ?? 0.0;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == 0
                                ? AppTheme.goldAccent
                                : index == 1
                                    ? Colors.grey
                                    : index == 2
                                        ? Colors.brown
                                        : AppTheme.darkBackground,
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              color: index < 3 ? Colors.black : AppTheme.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textWhite,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$qty units sold',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₱${sales.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldAccent,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

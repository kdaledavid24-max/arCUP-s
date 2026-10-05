import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Visual timeline widget displaying real-time order progression.
class StatusTracker extends StatelessWidget {
  final String currentStatus;
  final String orderType;

  const StatusTracker({
    super.key,
    required this.currentStatus,
    this.orderType = 'Delivery',
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = currentStatus.toLowerCase() == 'cancelled';
    final isDelivery = orderType.toLowerCase() == 'delivery';

    final steps = [
      {'title': 'Order Placed', 'subtitle': 'Received by kitchen', 'icon': Icons.receipt_long_rounded},
      {'title': 'Preparing', 'subtitle': 'Cooking & brewing', 'icon': Icons.soup_kitchen_rounded},
      {
        'title': isDelivery ? 'Out for Delivery' : 'Ready for Pickup',
        'subtitle': isDelivery ? 'Rider on the way' : 'Counter ready',
        'icon': isDelivery ? Icons.delivery_dining_rounded : Icons.storefront_rounded
      },
      {'title': 'Delivered', 'subtitle': 'Enjoy your meal!', 'icon': Icons.check_circle_rounded},
    ];

    int activeIndex = 0;
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        activeIndex = 0;
        break;
      case 'preparing':
        activeIndex = 1;
        break;
      case 'ready':
      case 'out for delivery':
        activeIndex = 2;
        break;
      case 'delivered':
      case 'completed':
        activeIndex = 3;
        break;
      default:
        activeIndex = 0;
    }

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Cancelled',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'This order has been cancelled.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final isCompleted = index <= activeIndex;
          final isCurrent = index == activeIndex;
          final isLast = index == steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator column
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? AppTheme.goldAccent
                          : isCompleted
                              ? AppTheme.successGreen
                              : AppTheme.darkBackground,
                      border: Border.all(
                        color: isCompleted
                            ? (isCurrent ? AppTheme.goldAccent : AppTheme.successGreen)
                            : AppTheme.cardBorder,
                        width: 2,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppTheme.goldAccent.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      steps[index]['icon'] as IconData,
                      size: 18,
                      color: isCurrent
                          ? Colors.black
                          : isCompleted
                              ? Colors.white
                              : AppTheme.textMuted,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 36,
                      color: index < activeIndex
                          ? AppTheme.successGreen
                          : AppTheme.cardBorder,
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Text column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index]['title'] as String,
                        style: TextStyle(
                          color: isCurrent
                              ? AppTheme.goldAccent
                              : isCompleted
                                  ? AppTheme.textWhite
                                  : AppTheme.textMuted,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        steps[index]['subtitle'] as String,
                        style: TextStyle(
                          color: isCurrent
                              ? AppTheme.textWhite.withValues(alpha: 0.8)
                              : AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      if (!isLast) const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

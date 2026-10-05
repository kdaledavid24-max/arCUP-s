import 'cart_item.dart';

/// Model representing a confirmed customer order.
class OrderModel {
  final String orderId;
  final DateTime date;
  final String customerName;
  final String contactNumber;
  final String orderType; // 'Dine-in' or 'Take-out'
  final String? tableNumber;
  final List<CartItem> items;
  final double totalAmount;
  final String status; // 'Pending', 'Preparing', 'Ready', 'Completed'
  final String estimatedTime;

  OrderModel({
    required this.orderId,
    required this.date,
    required this.customerName,
    required this.contactNumber,
    required this.orderType,
    this.tableNumber,
    required this.items,
    required this.totalAmount,
    this.status = 'Pending',
    this.estimatedTime = '15 - 20 mins',
  });
}

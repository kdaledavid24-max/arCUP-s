import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/local_storage_service.dart';

/// Provider managing customer orders, admin fulfillment, status transitions, and revenue analytics.
class OrderProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService.instance;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String _selectedStatusFilter = 'All';

  List<OrderModel> get allOrders => _orders;
  bool get isLoading => _isLoading;
  String get selectedStatusFilter => _selectedStatusFilter;

  OrderProvider() {
    loadOrders();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = (await _storage.getOrders()).toList();
    } catch (_) {
      _orders = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _selectedStatusFilter = filter;
    notifyListeners();
  }

  List<OrderModel> get filteredOrders {
    if (_selectedStatusFilter == 'All') return _orders;
    return _orders
        .where((o) => o.orderStatus.toLowerCase() == _selectedStatusFilter.toLowerCase())
        .toList();
  }

  List<OrderModel> getOrdersForUser(int userId) {
    return _orders.where((o) => o.userId == userId).toList();
  }

  OrderModel? getOrderById(int orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  Future<OrderModel> placeOrder({
    required int userId,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    required String orderType,
    required String paymentMethod,
    required double subtotal,
    required double deliveryFee,
    required double totalAmount,
    required List<OrderItemModel> items,
    String? notes,
  }) async {
    final order = await _storage.createOrder(
      userId: userId,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      orderType: orderType,
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      items: items,
      notes: notes,
    );
    await loadOrders();
    return order;
  }

  Future<void> updateStatus(int orderId, String newStatus, {String? paymentStatus}) async {
    await _storage.updateOrderStatus(orderId, newStatus, paymentStatus: paymentStatus);
    await loadOrders();
  }

  Future<void> cancelOrder(int orderId) async {
    await _storage.updateOrderStatus(orderId, 'Cancelled');
    await loadOrders();
  }

  // Analytics
  double get totalRevenue {
    return _orders
        .where((o) => o.orderStatus != 'Cancelled')
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  int get totalOrdersCount => _orders.length;

  int get pendingOrdersCount =>
      _orders.where((o) => o.orderStatus == 'Pending').length;

  int get activeOrdersCount =>
      _orders.where((o) => !o.isCompleted && !o.isCancelled).length;

  int get completedOrdersCount =>
      _orders.where((o) => o.isCompleted).length;
}

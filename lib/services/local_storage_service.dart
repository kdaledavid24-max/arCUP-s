import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/product.dart';
import '../models/order_model.dart';
import '../data/product_data.dart';

/// Local storage service for Food Ordering system.
/// Handles data persistence locally using SharedPreferences and in-memory fallback.
/// No external database server (Firebase/MySQL) required.
class LocalStorageService {
  static final LocalStorageService instance = LocalStorageService._init();
  LocalStorageService._init();

  static const String _keyUsers = 'fo_users';
  static const String _keyProducts = 'fo_products';
  static const String _keyOrders = 'fo_orders';
  static const String _keySeeded = 'fo_seeded_v1';
  static const String _keyCurrentUser = 'fo_current_user';

  Future<void>? _initFuture;

  // In-memory fallback if SharedPreferences is initializing or in web preview
  final List<UserModel> _memoryUsers = [];
  final List<Product> _memoryProducts = [];
  final List<OrderModel> _memoryOrders = [];

  Future<void> ensureReady() {
    return _initFuture ??= _seedIfNeeded();
  }

  Future<void> _seedIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isSeeded = prefs.getBool(_keySeeded) ?? false;

      if (!isSeeded) {
        // 1. Seed default users
        final defaultUsers = [
          UserModel(
            id: 1,
            name: 'System Admin',
            email: 'admin@foodordering.com',
            phone: '09171234567',
            password: 'admin123',
            role: 'admin',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
          UserModel(
            id: 2,
            name: 'David Capulong',
            email: 'customer@foodordering.com',
            phone: '09187654321',
            password: 'customer123',
            role: 'customer',
            address: 'Block 12, Golden Hills, Angeles City, Pampanga',
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
          ),
        ];

        // 2. Seed initial products from Food Ordering catalog
        final initialProducts = ProductData.products;

        // 3. Seed demo orders
        final demoOrders = [
          OrderModel(
            id: 1001,
            userId: 2,
            customerName: 'David Capulong',
            customerPhone: '09187654321',
            deliveryAddress: 'Block 12, Golden Hills, Angeles City, Pampanga',
            orderType: 'Delivery',
            paymentMethod: 'GCash',
            paymentStatus: 'Paid',
            orderStatus: 'Delivered',
            subtotal: 410.0,
            deliveryFee: 40.0,
            totalAmount: 450.0,
            notes: 'Less sugar on drinks please.',
            createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
            items: [
              OrderItemModel(
                productId: 'coffee_001',
                productName: 'Biscoff Latte',
                price: 160.0,
                quantity: 1,
                image: 'assets/images/drinks/biscoff_latte.jpg',
              ),
              OrderItemModel(
                productId: 'pasta_001',
                productName: 'Creamy Carbonara',
                price: 250.0,
                quantity: 1,
                image: 'assets/images/pasta/creamy_carbonara.jpg',
              ),
            ],
          ),
          OrderModel(
            id: 1002,
            userId: 2,
            customerName: 'David Capulong',
            customerPhone: '09187654321',
            deliveryAddress: 'Block 12, Golden Hills, Angeles City, Pampanga',
            orderType: 'Delivery',
            paymentMethod: 'Cash',
            paymentStatus: 'Pending',
            orderStatus: 'Preparing',
            subtotal: 355.0,
            deliveryFee: 40.0,
            totalAmount: 395.0,
            notes: 'Extra parmesan on pasta.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
            items: [
              OrderItemModel(
                productId: 'frappe_001',
                productName: 'Biscoff Frappe',
                price: 180.0,
                quantity: 1,
                image: 'assets/images/frappe/biscoff_frappe.jpg',
              ),
              OrderItemModel(
                productId: 'frappe_003',
                productName: 'Caramel Frappuccino',
                price: 175.0,
                quantity: 1,
                image: 'assets/images/frappe/caramel_frappuccino.jpg',
              ),
            ],
          ),
        ];

        await prefs.setString(_keyUsers, jsonEncode(defaultUsers.map((u) => u.toJson()).toList()));
        await prefs.setString(_keyProducts, jsonEncode(initialProducts.map((p) => p.toJson()).toList()));
        await prefs.setString(_keyOrders, jsonEncode(demoOrders.map((o) => o.toJson()).toList()));
        await prefs.setBool(_keySeeded, true);

        _memoryUsers.addAll(defaultUsers);
        _memoryProducts.addAll(initialProducts);
        _memoryOrders.addAll(demoOrders);
      } else {
        // Load into memory
        await getUsers();
        await getProducts();
        await getOrders();
      }
    } catch (e) {
      // Fallback in-memory
      if (_memoryProducts.isEmpty) {
        _memoryProducts.addAll(ProductData.products);
      }
    }
  }

  // ================= USER OPERATIONS =================
  Future<List<UserModel>> getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyUsers);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        _memoryUsers.clear();
        _memoryUsers.addAll(list.map((m) => UserModel.fromJson(Map<String, dynamic>.from(m as Map))));
        return List.unmodifiable(_memoryUsers);
      }
    } catch (_) {}
    return List.unmodifiable(_memoryUsers);
  }

  Future<UserModel?> authenticateUser(String email, String password) async {
    await ensureReady();
    final users = await getUsers();
    try {
      return users.firstWhere(
        (u) =>
            u.email.toLowerCase().trim() == email.toLowerCase().trim() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
    String role = 'customer',
  }) async {
    await ensureReady();
    final users = (await getUsers()).toList();

    final exists = users.any((u) => u.email.toLowerCase().trim() == email.toLowerCase().trim());
    if (exists) {
      throw Exception('An account with this email already exists.');
    }

    final newId = users.isEmpty ? 1 : users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
    final newUser = UserModel(
      id: newId,
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
      address: address,
      createdAt: DateTime.now(),
    );

    users.add(newUser);
    _memoryUsers.clear();
    _memoryUsers.addAll(users);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsers, jsonEncode(users.map((u) => u.toJson()).toList()));

    return newUser;
  }

  Future<void> saveCurrentSession(UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_keyCurrentUser);
    } else {
      await prefs.setString(_keyCurrentUser, jsonEncode(user.toJson()));
    }
  }

  Future<UserModel?> getCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyCurrentUser);
      if (raw != null && raw.isNotEmpty) {
        return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  // ================= PRODUCT OPERATIONS =================
  Future<List<Product>> getProducts() async {
    await ensureReady();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyProducts);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        _memoryProducts.clear();
        _memoryProducts.addAll(list.map((m) => Product.fromJson(Map<String, dynamic>.from(m as Map))));
        return List.unmodifiable(_memoryProducts);
      }
    } catch (_) {}
    if (_memoryProducts.isEmpty) {
      _memoryProducts.addAll(ProductData.products);
    }
    return List.unmodifiable(_memoryProducts);
  }

  Future<void> saveProduct(Product product) async {
    await ensureReady();
    final products = (await getProducts()).toList();
    final index = products.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      products[index] = product;
    } else {
      products.add(product);
    }

    _memoryProducts.clear();
    _memoryProducts.addAll(products);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProducts, jsonEncode(products.map((p) => p.toJson()).toList()));
  }

  Future<void> deleteProduct(String productId) async {
    await ensureReady();
    final products = (await getProducts()).toList();
    products.removeWhere((p) => p.id == productId);

    _memoryProducts.clear();
    _memoryProducts.addAll(products);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProducts, jsonEncode(products.map((p) => p.toJson()).toList()));
  }

  // ================= ORDER OPERATIONS =================
  Future<List<OrderModel>> getOrders() async {
    await ensureReady();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyOrders);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        _memoryOrders.clear();
        _memoryOrders.addAll(list.map((m) => OrderModel.fromJson(Map<String, dynamic>.from(m as Map))));
        return List.unmodifiable(_memoryOrders);
      }
    } catch (_) {}
    return List.unmodifiable(_memoryOrders);
  }

  Future<OrderModel> createOrder({
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
    await ensureReady();
    final orders = (await getOrders()).toList();

    final nextId = orders.isEmpty ? 1001 : orders.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1;

    final newOrder = OrderModel(
      id: nextId,
      userId: userId,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      orderType: orderType,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'Cash' ? 'Pending' : 'Paid',
      orderStatus: 'Pending',
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      notes: notes,
      createdAt: DateTime.now(),
      items: items,
    );

    orders.insert(0, newOrder);
    _memoryOrders.clear();
    _memoryOrders.addAll(orders);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOrders, jsonEncode(orders.map((o) => o.toJson()).toList()));

    return newOrder;
  }

  Future<void> updateOrderStatus(int orderId, String newStatus, {String? paymentStatus}) async {
    await ensureReady();
    final orders = (await getOrders()).toList();
    final index = orders.indexWhere((o) => o.id == orderId);

    if (index >= 0) {
      final old = orders[index];
      orders[index] = old.copyWith(
        orderStatus: newStatus,
        paymentStatus: paymentStatus ?? (newStatus == 'Delivered' || newStatus == 'Completed' ? 'Paid' : old.paymentStatus),
      );

      _memoryOrders.clear();
      _memoryOrders.addAll(orders);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyOrders, jsonEncode(orders.map((o) => o.toJson()).toList()));
    }
  }
}

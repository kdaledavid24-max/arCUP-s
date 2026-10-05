/// Item inside an order
class OrderItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? image;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.image,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'image': image,
      };

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        productId: json['productId']?.toString() ?? '',
        productName: json['productName']?.toString() ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        image: json['image']?.toString(),
      );
}

/// Order model for Food Ordering System
class OrderModel {
  final int id;
  final int userId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String orderType; // 'Delivery' or 'Pickup'
  final String paymentMethod; // 'Cash', 'GCash', 'Card'
  final String paymentStatus; // 'Paid', 'Pending'
  final String orderStatus; // 'Pending', 'Preparing', 'Ready', 'Out for Delivery', 'Delivered', 'Completed', 'Cancelled'
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.orderType,
    required this.paymentMethod,
    this.paymentStatus = 'Pending',
    this.orderStatus = 'Pending',
    required this.subtotal,
    this.deliveryFee = 0.0,
    required this.totalAmount,
    this.notes,
    DateTime? createdAt,
    required this.items,
  }) : createdAt = createdAt ?? DateTime.now();

  String get orderNumber => 'FO-${id.toString().padLeft(5, '0')}';

  bool get isCompleted =>
      orderStatus == 'Delivered' || orderStatus == 'Completed';
  bool get isCancelled => orderStatus == 'Cancelled';
  bool get isPending => orderStatus == 'Pending';

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'deliveryAddress': deliveryAddress,
        'orderType': orderType,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'orderStatus': orderStatus,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'totalAmount': totalAmount,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: (json['id'] as num).toInt(),
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        customerName: json['customerName']?.toString() ?? 'Customer',
        customerPhone: json['customerPhone']?.toString() ?? '',
        deliveryAddress: json['deliveryAddress']?.toString() ?? '',
        orderType: json['orderType']?.toString() ?? 'Delivery',
        paymentMethod: json['paymentMethod']?.toString() ?? 'Cash',
        paymentStatus: json['paymentStatus']?.toString() ?? 'Pending',
        orderStatus: json['orderStatus']?.toString() ?? 'Pending',
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        items: (json['items'] as List<dynamic>?)
                ?.map((i) => OrderItemModel.fromJson(Map<String, dynamic>.from(i as Map)))
                .toList() ??
            [],
      );

  OrderModel copyWith({
    int? id,
    int? userId,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    String? orderType,
    String? paymentMethod,
    String? paymentStatus,
    String? orderStatus,
    double? subtotal,
    double? deliveryFee,
    double? totalAmount,
    String? notes,
    DateTime? createdAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderType: orderType ?? this.orderType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}

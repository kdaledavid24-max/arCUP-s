/// User model for Food Ordering system supporting customer and admin roles.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role; // 'customer' or 'admin'
  final String? address;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.address,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        'address': address,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        password: json['password'] as String? ?? '',
        role: json['role'] as String? ?? 'customer',
        address: json['address'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? role,
    String? address,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

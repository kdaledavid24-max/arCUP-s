/// Model class representing a food or drink product in Food Ordering System.
class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String image;
  final bool available;
  final double rating;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.image,
    this.available = true,
    this.rating = 4.8,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'image': image,
        'available': available,
        'rating': rating,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        category: json['category']?.toString() ?? 'Coffee & Espresso',
        description: json['description']?.toString() ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        image: json['image']?.toString() ?? 'assets/images/drinks/americano.jpg',
        available: json['available'] as bool? ?? true,
        rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      );

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? price,
    String? image,
    bool? available,
    double? rating,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      available: available ?? this.available,
      rating: rating ?? this.rating,
    );
  }
}

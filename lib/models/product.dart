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
  final bool isSpecial;
  final String? specialNote;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.image,
    this.available = true,
    this.rating = 4.8,
    this.isSpecial = false,
    this.specialNote,
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
        'isSpecial': isSpecial,
        'specialNote': specialNote,
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
        isSpecial: json['isSpecial'] as bool? ?? false,
        specialNote: json['specialNote']?.toString(),
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
    bool? isSpecial,
    String? specialNote,
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
      isSpecial: isSpecial ?? this.isSpecial,
      specialNote: specialNote ?? this.specialNote,
    );
  }
}

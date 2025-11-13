class Product {
  final int id;
  final int restaurantId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final bool isFavorite;
  final double rating;
  final int reviewCount;
  final List<String>? tags;
  final List<ProductOption>? options;

  Product({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isAvailable = true,
    this.isFavorite = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.tags,
    this.options,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      restaurantId: json['restaurantId'] ?? json['restaurant_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      isFavorite: json['isFavorite'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? json['review_count'] ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => ProductOption.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'isFavorite': isFavorite,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
      'options': options?.map((e) => e.toJson()).toList(),
    };
  }

  Product copyWith({
    int? id,
    int? restaurantId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    bool? isFavorite,
    double? rating,
    int? reviewCount,
    List<String>? tags,
    List<ProductOption>? options,
  }) {
    return Product(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      tags: tags ?? this.tags,
      options: options ?? this.options,
    );
  }
}

class ProductOption {
  final String name;
  final List<String> choices;
  final double additionalPrice;

  ProductOption({
    required this.name,
    required this.choices,
    this.additionalPrice = 0.0,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      name: json['name'] ?? '',
      choices:
          (json['choices'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      additionalPrice:
          (json['additionalPrice'] ?? json['additional_price'] ?? 0.0)
              .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'choices': choices,
      'additionalPrice': additionalPrice,
    };
  }
}

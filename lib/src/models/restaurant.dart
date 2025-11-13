class Restaurant {
  final int id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final double rating;
  final String imageUrl;
  final bool isActive;
  final bool isFavorite;
  final double deliveryFee;
  final int deliveryTime; // minutos
  final List<String> categories;
  final double latitude;
  final double longitude;
  final String openingHours;
  final String? coverImageUrl;
  final double? averagePrice; // Precio promedio de platos

  // 🏷️ PROMOCIONES
  final bool hasPromotion;
  final String? promotionTitle;
  final String? promotionDescription;
  final int? discountPercentage;

  // 💰 PRECIOS
  final String priceRange; // "$", "$$", "$$$", "$$$$"
  final double? minPrice;
  final double? maxPrice;

  // 🕒 HORARIOS
  final bool isOpenNow;
  final String todaySchedule;

  // ⭐ RESEÑAS
  final int reviewCount;
  final double? distanceKm; // Distancia desde ubicación del usuario

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.rating,
    required this.imageUrl,
    this.isActive = true,
    this.isFavorite = false,
    this.deliveryFee = 0.0,
    this.deliveryTime = 30,
    this.categories = const [],
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.openingHours = '9:00 AM - 10:00 PM',
    this.coverImageUrl,
    this.averagePrice,
    this.hasPromotion = false,
    this.promotionTitle,
    this.promotionDescription,
    this.discountPercentage,
    this.priceRange = '\$\$',
    this.minPrice,
    this.maxPrice,
    this.isOpenNow = true,
    this.todaySchedule = '9:00 AM - 10:00 PM',
    this.reviewCount = 0,
    this.distanceKm,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      isFavorite: json['isFavorite'] ?? false,
      deliveryFee: (json['deliveryFee'] ?? json['delivery_fee'] ?? 0.0)
          .toDouble(),
      deliveryTime: json['deliveryTime'] ?? json['delivery_time'] ?? 30,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      openingHours:
          json['openingHours'] ?? json['opening_hours'] ?? '9:00 AM - 10:00 PM',
      coverImageUrl: json['coverImageUrl'] ?? json['cover_image_url'],
      averagePrice: json['averagePrice'] != null
          ? (json['averagePrice'] as num).toDouble()
          : json['average_price'] != null
          ? (json['average_price'] as num).toDouble()
          : null,
      // Promociones
      hasPromotion: json['hasPromotion'] ?? json['has_promotion'] ?? false,
      promotionTitle: json['promotionTitle'] ?? json['promotion_title'],
      promotionDescription:
          json['promotionDescription'] ?? json['promotion_description'],
      discountPercentage:
          json['discountPercentage'] ?? json['discount_percentage'],
      // Precios
      priceRange: json['priceRange'] ?? json['price_range'] ?? '\$\$',
      minPrice: json['minPrice'] != null
          ? (json['minPrice'] as num).toDouble()
          : json['min_price'] != null
          ? (json['min_price'] as num).toDouble()
          : null,
      maxPrice: json['maxPrice'] != null
          ? (json['maxPrice'] as num).toDouble()
          : json['max_price'] != null
          ? (json['max_price'] as num).toDouble()
          : null,
      // Horarios
      isOpenNow: json['isOpenNow'] ?? json['is_open_now'] ?? true,
      todaySchedule:
          json['todaySchedule'] ??
          json['today_schedule'] ??
          '9:00 AM - 10:00 PM',
      // Reseñas
      reviewCount: json['reviewCount'] ?? json['review_count'] ?? 0,
      // Distancia
      distanceKm: json['distanceKm'] != null
          ? (json['distanceKm'] as num).toDouble()
          : json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'rating': rating,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'isFavorite': isFavorite,
      'deliveryFee': deliveryFee,
      'deliveryTime': deliveryTime,
      'categories': categories,
      'latitude': latitude,
      'longitude': longitude,
      'openingHours': openingHours,
      'coverImageUrl': coverImageUrl,
      'averagePrice': averagePrice,
      // Promociones
      'hasPromotion': hasPromotion,
      if (promotionTitle != null) 'promotionTitle': promotionTitle,
      if (promotionDescription != null)
        'promotionDescription': promotionDescription,
      if (discountPercentage != null) 'discountPercentage': discountPercentage,
      // Precios
      'priceRange': priceRange,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      // Horarios
      'isOpenNow': isOpenNow,
      'todaySchedule': todaySchedule,
      // Reseñas
      'reviewCount': reviewCount,
      // Distancia
      if (distanceKm != null) 'distanceKm': distanceKm,
    };
  }

  Restaurant copyWith({
    int? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    double? rating,
    String? imageUrl,
    bool? isActive,
    bool? isFavorite,
    double? deliveryFee,
    int? deliveryTime,
    List<String>? categories,
    double? latitude,
    double? longitude,
    String? openingHours,
    String? coverImageUrl,
    double? averagePrice,
    // Promociones
    bool? hasPromotion,
    String? promotionTitle,
    String? promotionDescription,
    int? discountPercentage,
    // Precios
    String? priceRange,
    double? minPrice,
    double? maxPrice,
    // Horarios
    bool? isOpenNow,
    String? todaySchedule,
    // Reseñas
    int? reviewCount,
    // Distancia
    double? distanceKm,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      isFavorite: isFavorite ?? this.isFavorite,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      categories: categories ?? this.categories,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      openingHours: openingHours ?? this.openingHours,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      averagePrice: averagePrice ?? this.averagePrice,
      // Promociones
      hasPromotion: hasPromotion ?? this.hasPromotion,
      promotionTitle: promotionTitle ?? this.promotionTitle,
      promotionDescription: promotionDescription ?? this.promotionDescription,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      // Precios
      priceRange: priceRange ?? this.priceRange,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      // Horarios
      isOpenNow: isOpenNow ?? this.isOpenNow,
      todaySchedule: todaySchedule ?? this.todaySchedule,
      // Reseñas
      reviewCount: reviewCount ?? this.reviewCount,
      // Distancia
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

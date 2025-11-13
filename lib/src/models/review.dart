class Review {
  final int id;
  final int orderId;
  final int userId;
  final String userName;
  final int restaurantId;
  final String restaurantName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? images;

  Review({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.restaurantId,
    required this.restaurantName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      orderId: json['orderId'] ?? json['order_id'] ?? 0,
      userId: json['userId'] ?? json['user_id'] ?? 0,
      userName: json['userName'] ?? json['user_name'] ?? '',
      restaurantId: json['restaurantId'] ?? json['restaurant_id'] ?? 0,
      restaurantName: json['restaurantName'] ?? json['restaurant_name'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
    };
  }
}

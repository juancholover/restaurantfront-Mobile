enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  onTheWay,
  delivered,
  cancelled,
}

class Order {
  final int id;
  final int userId;
  final int restaurantId;
  final String restaurantName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final String deliveryAddress;
  final OrderStatus status;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryTime;
  final String? specialInstructions;
  final DeliveryDriver? driver;

  Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.estimatedDeliveryTime,
    this.specialInstructions,
    this.driver,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? json['user_id'] ?? 0,
      restaurantId: json['restaurantId'] ?? json['restaurant_id'] ?? 0,
      restaurantName: json['restaurantName'] ?? json['restaurant_name'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? json['delivery_fee'] ?? 0.0)
          .toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0.0)
          .toDouble(),
      deliveryAddress:
          json['deliveryAddress'] ?? json['delivery_address'] ?? '',
      status: _parseOrderStatus(json['status']),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.parse(json['estimatedDeliveryTime'])
          : null,
      specialInstructions:
          json['specialInstructions'] ?? json['special_instructions'],
      driver: json['driver'] != null
          ? DeliveryDriver.fromJson(json['driver'])
          : null,
    );
  }

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'on_the_way':
      case 'ontheway':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'specialInstructions': specialInstructions,
      'driver': driver?.toJson(),
    };
  }
}

class OrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? json['product_id'] ?? 0,
      productName: json['productName'] ?? json['product_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class DeliveryDriver {
  final int id;
  final String name;
  final String phone;
  final String? photoUrl;
  final double? currentLatitude;
  final double? currentLongitude;

  DeliveryDriver({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory DeliveryDriver.fromJson(Map<String, dynamic> json) {
    return DeliveryDriver(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'] ?? json['photo_url'],
      currentLatitude: json['currentLatitude'] != null
          ? (json['currentLatitude'] as num).toDouble()
          : null,
      currentLongitude: json['currentLongitude'] != null
          ? (json['currentLongitude'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
    };
  }
}

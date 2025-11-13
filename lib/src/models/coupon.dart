class Coupon {
  final int id;
  final String code;
  final String description;
  final String discountType;
  final double discountValue;
  final double minimumAmount;
  final double? maximumDiscount;
  final bool isActive;
  final String expiresAt;
  final int usageLimit;
  final int usageCount;
  final int userUsageLimit;
  final String createdAt;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minimumAmount,
    this.maximumDiscount,
    required this.isActive,
    required this.expiresAt,
    required this.usageLimit,
    required this.usageCount,
    required this.userUsageLimit,
    required this.createdAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as int,
      code: json['code'] as String,
      description: json['description'] as String,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      minimumAmount: (json['minimumAmount'] as num).toDouble(),
      maximumDiscount: json['maximumDiscount'] != null
          ? (json['maximumDiscount'] as num).toDouble()
          : null,
      isActive: json['isActive'] as bool,
      expiresAt: json['expiresAt'] as String,
      usageLimit: json['usageLimit'] as int,
      usageCount: json['usageCount'] as int,
      userUsageLimit: json['userUsageLimit'] as int,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minimumAmount': minimumAmount,
      'maximumDiscount': maximumDiscount,
      'isActive': isActive,
      'expiresAt': expiresAt,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'userUsageLimit': userUsageLimit,
      'createdAt': createdAt,
    };
  }

  // Verificar si el cupón está expirado
  bool get isExpired {
    try {
      final expirationDate = DateTime.parse(expiresAt);
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      return false;
    }
  }

  // Verificar si el cupón está disponible
  bool get isAvailable {
    return isActive && !isExpired && usageCount < usageLimit;
  }

  // Obtener el texto del descuento
  String get discountText {
    if (discountType == 'PERCENTAGE') {
      return '${discountValue.toStringAsFixed(0)}% OFF';
    } else {
      return 'S/${discountValue.toStringAsFixed(2)} OFF';
    }
  }

  // Calcular el descuento para un monto dado
  double calculateDiscount(double amount) {
    if (amount < minimumAmount) return 0.0;

    double discount;
    if (discountType == 'PERCENTAGE') {
      discount = amount * (discountValue / 100);
      if (maximumDiscount != null && discount > maximumDiscount!) {
        discount = maximumDiscount!;
      }
    } else {
      discount = discountValue;
    }

    return discount;
  }

  @override
  String toString() {
    return 'Coupon(code: $code, discount: $discountText, min: S/$minimumAmount)';
  }
}

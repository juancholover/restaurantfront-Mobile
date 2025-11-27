class Address {
  final int? id;
  final String label;
  final String addressLine;
  final String city;
  final String? postalCode;
  final double latitude;
  final double longitude;
  final String? additionalInfo;
  final bool isDefault;

  Address({
    this.id,
    required this.label,
    required this.addressLine,
    required this.city,
    this.postalCode,
    required this.latitude,
    required this.longitude,
    this.additionalInfo,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      label: json['label'] ?? '',
      addressLine: json['addressLine'] ?? json['address_line'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? json['postal_code'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      additionalInfo: json['additionalInfo'] ?? json['additional_info'],
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'addressLine': addressLine,
      'city': city,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'additionalInfo': additionalInfo,
      'isDefault': isDefault,
    };
  }

  Address copyWith({
    int? id,
    String? label,
    String? addressLine,
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? additionalInfo,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

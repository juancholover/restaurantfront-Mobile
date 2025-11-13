import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String? specialInstructions;
  final Map<String, String>? selectedOptions;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.specialInstructions,
    this.selectedOptions,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? specialInstructions,
    Map<String, String>? selectedOptions,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'selectedOptions': selectedOptions,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['specialInstructions'],
      selectedOptions: json['selectedOptions'] != null
          ? Map<String, String>.from(json['selectedOptions'])
          : null,
    );
  }
}

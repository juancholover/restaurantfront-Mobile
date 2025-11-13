import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  final Map<int, List<Product>> _productsByRestaurant = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Obtener productos de un restaurante
  Future<void> fetchProductsByRestaurant(int restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _productService.getProductsByRestaurant(
        restaurantId,
      );
      _productsByRestaurant[restaurantId] = products;
      _products = products;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      _error = 'Error al cargar productos: ${e.toString()}';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener productos ya cargados de un restaurante
  List<Product> getRestaurantProducts(int restaurantId) {
    return _productsByRestaurant[restaurantId] ?? [];
  }

  // Limpiar
  void clear() {
    _products = [];
    _error = null;
    notifyListeners();
  }
}

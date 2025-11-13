import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // Obtener todos los productos
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _apiService.get('/products');

      if (response['success'] == true) {
        return (response['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Error al cargar productos');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  // Obtener productos de un restaurante
  Future<List<Product>> getProductsByRestaurant(int restaurantId) async {
    try {
      final response = await _apiService.get(
        '/products/restaurant/$restaurantId',
      );

      if (response['success'] == true) {
        return (response['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Error al cargar productos');
      }
    } catch (e) {
      debugPrint('Error fetching restaurant products: $e');
      rethrow;
    }
  }

  // Obtener un producto por ID
  Future<Product> getProductById(int productId) async {
    try {
      final response = await _apiService.get('/products/$productId');

      if (response['success'] == true) {
        return Product.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Error al cargar producto');
      }
    } catch (e) {
      debugPrint('Error fetching product: $e');
      rethrow;
    }
  }
}

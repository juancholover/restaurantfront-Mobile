import 'package:flutter/foundation.dart';
import '../models/review.dart';
import 'api_service.dart';

class ReviewService {
  final ApiService _apiService = ApiService();

  // Crear una reseña
  Future<Review> createReview({
    int? orderId,
    required int restaurantId,
    required double rating,
    required String comment,
    String? restaurantName,
    List<String>? images,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'restaurantId': restaurantId,
        'rating': rating,
        'comment': comment,
        if (restaurantName != null) 'restaurantName': restaurantName,
        if (images != null && images.isNotEmpty) 'images': images,
      };

      if (orderId != null && orderId != 0) {
        body['orderId'] = orderId;
      }

      final response = await _apiService.post(
        '/reviews',
        body,
        requiresAuth: true,
      );

      if (response['success'] == true) {
        return Review.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Error al crear reseña');
      }
    } catch (e) {
      debugPrint('Error creating review: $e');
      rethrow;
    }
  }

  // Obtener reseñas de un restaurante
  Future<List<Review>> getRestaurantReviews(int restaurantId) async {
    try {
      final response = await _apiService.get(
        '/reviews/restaurant/$restaurantId',
      );

      if (response['success'] == true) {
        return (response['data'] as List)
            .map((json) => Review.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Error al cargar reseñas');
      }
    } catch (e) {
      debugPrint('Error fetching restaurant reviews: $e');
      rethrow;
    }
  }

  // Verificar si el usuario ya hizo una reseña para un pedido
  Future<bool> hasReviewForOrder(int orderId) async {
    try {
      final response = await _apiService.get(
        '/reviews/order/$orderId/check',
        requiresAuth: true,
      );

      return response['data']?['hasReview'] ?? false;
    } catch (e) {
      debugPrint('Error checking review: $e');
      return false;
    }
  }

  // Obtener mis reseñas
  Future<List<Review>> getMyReviews() async {
    try {
      final response = await _apiService.get('/reviews/my', requiresAuth: true);

      if (response['success'] == true) {
        return (response['data'] as List)
            .map((json) => Review.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Error al cargar reseñas');
      }
    } catch (e) {
      debugPrint('Error fetching my reviews: $e');
      rethrow;
    }
  }
}

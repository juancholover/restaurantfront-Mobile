import '../models/restaurant.dart';
import 'api_service.dart';

/// Servicio para operaciones relacionadas con restaurantes
class RestaurantService {
  final ApiService _apiService = ApiService();

  /// Obtiene un restaurante por su ID
  Future<Restaurant> getRestaurantById(int id) async {
    try {
      final response = await _apiService.get('/restaurants/$id');

      if (response['success'] == true) {
        return Restaurant.fromJson(response['data']);
      } else {
        throw Exception(
          response['message'] ?? 'Error al cargar el restaurante',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener restaurante: $e');
    }
  }

  /// Obtiene todos los restaurantes
  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final response = await _apiService.get('/restaurants');

      if (response['success'] == true) {
        return (response['data'] as List)
            .map((json) => Restaurant.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Error al cargar restaurantes');
      }
    } catch (e) {
      throw Exception('Error al obtener restaurantes: $e');
    }
  }
}

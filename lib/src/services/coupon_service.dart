import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Servicio para gestionar cupones de descuento
class CouponService {
  final ApiService _apiService = ApiService();

  /// Validar un cupón con el backend
  Future<Map<String, dynamic>?> validateCoupon(
    String code,
    double cartTotal,
  ) async {
    try {
      final token = await _apiService.getToken();

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/coupons/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'code': code.toUpperCase(), 'cartTotal': cartTotal}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }

      return null;
    } catch (e) {
      throw Exception('Error al validar cupón: $e');
    }
  }

  /// Obtener cupones activos (no requiere autenticación)
  Future<List<Map<String, dynamic>>> getActiveCoupons() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/coupons/active'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }

      return [];
    } catch (e) {
      throw Exception('Error al obtener cupones activos: $e');
    }
  }

  /// Obtener historial de cupones del usuario
  Future<List<Map<String, dynamic>>> getCouponHistory() async {
    try {
      final token = await _apiService.getToken();

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/coupons/history'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }

      return [];
    } catch (e) {
      throw Exception('Error al obtener historial de cupones: $e');
    }
  }

  /// Crear un nuevo cupón (ADMIN)
  Future<Map<String, dynamic>?> createCoupon({
    required String code,
    required String description,
    required String discountType, // 'FIXED' o 'PERCENTAGE'
    required double discountValue,
    required double minimumAmount,
    double? maximumDiscount,
    bool isActive = true,
    required String expiresAt, // ISO 8601: "2025-12-31T23:59:59"
    required int usageLimit,
    required int userUsageLimit,
  }) async {
    try {
      final token = await _apiService.getToken();

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/coupons'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'code': code.toUpperCase(),
          'description': description,
          'discountType': discountType,
          'discountValue': discountValue,
          'minimumAmount': minimumAmount,
          'maximumDiscount': maximumDiscount,
          'isActive': isActive,
          'expiresAt': expiresAt,
          'usageLimit': usageLimit,
          'userUsageLimit': userUsageLimit,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }

      return null;
    } catch (e) {
      throw Exception('Error al crear cupón: $e');
    }
  }
}

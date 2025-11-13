import 'package:flutter/foundation.dart';
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  Future<Order> createOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double deliveryFee,
    required double totalAmount,
    required String deliveryAddress,
    String? notes,
    String? paymentMethod,
    String? paymentStatus,
    String? paymentIntentId, // ← Nuevo parámetro
  }) async {
    try {
      final response = await _apiService.post('/orders', {
        'restaurantId': restaurantId,
        'items': items,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'totalAmount': totalAmount,
        'deliveryAddress': deliveryAddress,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (paymentStatus != null) 'paymentStatus': paymentStatus,
        if (paymentIntentId != null)
          'paymentIntentId': paymentIntentId, // ← Enviar al backend
      }, requiresAuth: true);

      if (response['success'] == true) {
        return Order.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Error al crear orden');
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  // Obtener mis órdenes
  Future<List<Order>> getMyOrders() async {
    try {
      final response = await _apiService.get('/orders', requiresAuth: true);

      if (response['success'] == true) {
        return (response['data'] as List)
            .map((json) => Order.fromJson(json))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Error al cargar órdenes');
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      rethrow;
    }
  }

  // Obtener orden por ID
  Future<Order> getOrderById(int orderId) async {
    try {
      final response = await _apiService.get(
        '/orders/$orderId',
        requiresAuth: true,
      );

      if (response['success'] == true) {
        return Order.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Error al cargar orden');
      }
    } catch (e) {
      debugPrint('Error fetching order: $e');
      rethrow;
    }
  }

  // Actualizar estado de orden (solo admin)
  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await _apiService.put(
        '/orders/$orderId/status?status=$status',
        {},
        requiresAuth: true,
      );

      return response['success'] == true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  // Marcar orden como entregada
  Future<Order> markAsDelivered(int orderId) async {
    try {
      final response = await _apiService.post(
        '/orders/$orderId/deliver',
        {},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        debugPrint('✅ Orden #$orderId marcada como entregada');
        return Order.fromJson(response['data']);
      } else {
        throw Exception(
          response['message'] ?? 'Error al marcar como entregada',
        );
      }
    } catch (e) {
      debugPrint('Error marking order as delivered: $e');
      rethrow;
    }
  }

  // Cancelar orden
  Future<Order> cancelOrder(int orderId, String? reason) async {
    try {
      final url = reason != null
          ? '/orders/$orderId/cancel?reason=${Uri.encodeComponent(reason)}'
          : '/orders/$orderId/cancel';

      final response = await _apiService.post(url, {}, requiresAuth: true);

      if (response['success'] == true) {
        debugPrint('❌ Orden #$orderId cancelada');
        return Order.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Error al cancelar orden');
      }
    } catch (e) {
      debugPrint('Error canceling order: $e');
      rethrow;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/error_response.dart';

class ApiService {
  // 🔧 CONFIGURACIÓN - Detecta automáticamente el entorno
  static String get baseUrl {
    if (kIsWeb) {
      // Para web (Chrome, Edge, etc.)
      return 'http://localhost:8080/api';
    } else {
      // Para emulador Android
      return 'http://10.0.2.2:8080/api';
      // Para dispositivo físico en la misma red: 'http://TU_IP:8080/api'
      // Para producción: 'https://tu-dominio.com/api'
    }
  }

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  // Obtener token guardado
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Guardar token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Eliminar token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Headers comunes
  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Manejo de respuesta
  dynamic _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        // Parsear ErrorResponse del backend
        final errorResponse = ErrorResponse.fromJson(body);
        throw ApiException(
          statusCode: response.statusCode,
          message: errorResponse.message,
          errorResponse: errorResponse,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;

      // Error de parsing JSON
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Error al procesar la respuesta del servidor',
      );
    }
  }

  // GET
  Future<dynamic> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // POST
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // PUT
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE
  Future<dynamic> delete(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}

// Excepción personalizada
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final ErrorResponse? errorResponse;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errorResponse,
  });

  @override
  String toString() => message;
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'notification_service.dart';

class AuthService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  bool _isLoggedIn = false;
  bool _isInitializing = true;
  Map<String, dynamic>? _userData;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;
  String? get userEmail => _userData?['email'];
  String? get userName => _userData?['name'];
  Map<String, dynamic>? get userData => _userData;

  Future<void> init() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) {
        // Verificar si el token es válido obteniendo el perfil
        final response = await _apiService.get(
          '/auth/profile',
          requiresAuth: true,
        );
        if (response['success'] == true) {
          _isLoggedIn = true;
          _userData = response['data'];
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      await logout();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });

      if (response['success'] == true) {
        // El registro solo devuelve user, no token
        // Hacer login automáticamente después del registro
        return await login(email: email, password: password);
      }

      return false;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        final token = response['data']['token'];
        final user = response['data']['user'];

        await _apiService.saveToken(token);
        _isLoggedIn = true;
        _userData = user;
        notifyListeners();

        // Registrar token FCM en el backend después del login
        final fcmToken = _notificationService.fcmToken;
        if (fcmToken != null) {
          await _notificationService.registerTokenWithBackend(fcmToken);
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    // Eliminar token FCM del backend antes de cerrar sesión
    await _notificationService.unregisterTokenFromBackend();

    _isLoggedIn = false;
    _userData = null;
    await _apiService.deleteToken();
    await _storage.delete(key: _userKey);
    notifyListeners();
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutterlogin/src/services/api_service.dart';
import 'package:flutterlogin/src/services/navigation_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Mensaje en segundo plano: ${message.messageId}');
}

/// Servicio para manejar notificaciones push con Firebase Cloud Messaging
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  bool _initialized = false;
  String? _fcmToken;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      await _requestPermissions();

      await _initializeLocalNotifications();

      _fcmToken = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: $_fcmToken');

      // Enviar token inicial al backend si hay usuario autenticado
      if (_fcmToken != null) {
        await registerTokenWithBackend(_fcmToken!);
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('🔄 Token actualizado: $newToken');
        registerTokenWithBackend(newToken);
      });

      _setupMessageHandlers();

      _initialized = true;
      print('✅ NotificationService inicializado');
    } catch (e) {
      print('❌ Error inicializando NotificationService: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permisos de notificación concedidos');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('⚠️ Permisos de notificación provisionales concedidos');
    } else {
      print('❌ Permisos de notificación denegados');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificaciones para Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notificaciones importantes',
      description: 'Canal para notificaciones de pedidos y ofertas',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Configura los handlers para diferentes estados de la app
  void _setupMessageHandlers() {
    // Cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Mensaje recibido (app en primer plano): ${message.messageId}');
      _showLocalNotification(message);
    });

    // Cuando el usuario toca la notificación y la app estaba en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 App abierta desde notificación: ${message.messageId}');
      _handleNotificationTap(message.data);
    });

    // Verificar si la app se abrió desde una notificación (cuando estaba cerrada)
    _checkInitialMessage();
  }

  /// Verifica si la app se abrió desde una notificación
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('🚀 App iniciada desde notificación: ${initialMessage.messageId}');
      _handleNotificationTap(initialMessage.data);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Notificaciones importantes',
            channelDescription:
                'Canal para notificaciones de pedidos y ofertas',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Maneja el tap en una notificación local
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notificación tocada: ${response.payload}');
    if (response.payload != null) {
      try {
        // El payload viene como string del Map de data
        // Intentar parsear si es JSON
        final payload = response.payload!;
        if (payload.startsWith('{')) {
          // Es un JSON string, parsearlo
          // Nota: Para navegación real necesitas NavigatorKey global
          print('📲 Payload parseado para navegación');
        }
      } catch (e) {
        print('❌ Error parseando payload: $e');
      }
    }
  }

  /// Maneja el tap en una notificación de Firebase
  void _handleNotificationTap(Map<String, dynamic> data) {
    print('📲 Data de notificación: $data');

    // Tipos de notificaciones:
    // - order_status: Estado de pedido actualizado
    // - special_offer: Oferta especial disponible
    // - new_restaurant: Nuevo restaurante disponible

    final type = data['type'];
    final idStr = data['orderId'] ?? data['id'];

    try {
      switch (type) {
        case 'order_status':
          print('🍽️ Navegar a pedido #$idStr');
          final orderId = int.tryParse(idStr.toString());
          if (orderId != null) {
            NavigationService.navigatorKey.currentState?.pushNamed(
              '/order-detail',
              arguments: orderId,
            );
          }
          break;
        case 'special_offer':
          print('🎁 Navegar a cupones');
          NavigationService.navigatorKey.currentState?.pushNamed(
            '/coupon-history',
          );
          break;
        case 'new_restaurant':
          print('🏪 Navegar a restaurantes');
          NavigationService.navigatorKey.currentState?.pushNamed(
            '/restaurants',
          );
          break;
        default:
          print('❓ Tipo de notificación desconocido: $type');
          // Navegar a main screen por defecto
          NavigationService.navigatorKey.currentState?.pushNamed('/main');
      }
    } catch (e) {
      print('❌ Error navegando desde notificación: $e');
    }
  }

  String? get fcmToken => _fcmToken;

  /// Suscribe a un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Suscrito a topic: $topic');
    } catch (e) {
      print('❌ Error suscribiendo a topic $topic: $e');
    }
  }

  /// Cancela suscripción a un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('❌ Desuscrito de topic: $topic');
    } catch (e) {
      print('❌ Error desuscribiendo de topic $topic: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      print('🗑️ Token FCM eliminado');
    } catch (e) {
      print('❌ Error eliminando token: $e');
    }
  }

  /// Obtener nombre del dispositivo
  Future<String> _getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} (${iosInfo.model})';
      }
      return 'Unknown Device';
    } catch (e) {
      print('⚠️ Error obteniendo nombre del dispositivo: $e');
      return 'Unknown Device';
    }
  }

  /// Registrar token FCM en el backend
  Future<void> registerTokenWithBackend(String token) async {
    try {
      final authToken = await _apiService.getToken();

      if (authToken == null) {
        print('⚠️ Usuario no autenticado, no se registra FCM token');
        return;
      }

      final deviceName = await _getDeviceName();
      final deviceType = Platform.isAndroid
          ? 'ANDROID'
          : Platform.isIOS
          ? 'IOS'
          : 'WEB';

      final response = await _apiService.post('/fcm/token', {
        'token': token,
        'deviceType': deviceType,
        'deviceName': deviceName,
      }, requiresAuth: true);

      if (response['success'] == true) {
        print('✅ Token FCM registrado en backend');
        print('   Dispositivo: $deviceName ($deviceType)');
      } else {
        print('⚠️ Respuesta inesperada del backend: $response');
      }
    } catch (e) {
      print('❌ Error registrando token en backend: $e');
      // No lanzar error, solo registrar
    }
  }

  /// Eliminar token FCM del backend (logout)
  Future<void> unregisterTokenFromBackend() async {
    try {
      if (_fcmToken == null) {
        print('⚠️ No hay token FCM para eliminar');
        return;
      }

      final response = await _apiService.delete(
        '/fcm/token?token=$_fcmToken',
        requiresAuth: false,
      );

      if (response['success'] == true) {
        print('✅ Token FCM eliminado del backend');
      }

      // Eliminar token local de Firebase
      await deleteToken();
    } catch (e) {
      print('❌ Error eliminando token del backend: $e');
      // No lanzar error, solo registrar
    }
  }
}

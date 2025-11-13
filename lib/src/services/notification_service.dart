import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handler para mensajes en segundo plano (top-level function)
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

  bool _initialized = false;
  String? _fcmToken;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Inicializar Firebase
      await Firebase.initializeApp();

      // Configurar handler para mensajes en segundo plano
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Solicitar permisos
      await _requestPermissions();

      // Configurar notificaciones locales
      await _initializeLocalNotifications();

      // Obtener token FCM
      _fcmToken = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: $_fcmToken');

      // Escuchar cambios de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('🔄 Token actualizado: $newToken');
        // TODO: Enviar token al backend
      });

      // Configurar handlers de mensajes
      _setupMessageHandlers();

      _initialized = true;
      print('✅ NotificationService inicializado');
    } catch (e) {
      print('❌ Error inicializando NotificationService: $e');
    }
  }

  /// Solicita permisos de notificación
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

  /// Inicializa notificaciones locales (para mostrar cuando app está abierta)
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

  /// Muestra una notificación local (cuando la app está en primer plano)
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
    // TODO: Navegar a la pantalla correspondiente
  }

  /// Maneja el tap en una notificación de Firebase
  void _handleNotificationTap(Map<String, dynamic> data) {
    print('📲 Data de notificación: $data');

    // Tipos de notificaciones:
    // - order_status: Estado de pedido actualizado
    // - special_offer: Oferta especial disponible
    // - new_restaurant: Nuevo restaurante disponible

    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'order_status':
        // TODO: Navegar a detalle de pedido
        print('🍽️ Navegar a pedido #$id');
        break;
      case 'special_offer':
        // TODO: Navegar a ofertas
        print('🎁 Navegar a ofertas');
        break;
      case 'new_restaurant':
        // TODO: Navegar a restaurante
        print('🏪 Navegar a restaurante #$id');
        break;
      default:
        print('❓ Tipo de notificación desconocido: $type');
    }
  }

  /// Obtiene el token FCM actual
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

  /// Elimina el token FCM (cuando el usuario cierra sesión)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      print('🗑️ Token FCM eliminado');
    } catch (e) {
      print('❌ Error eliminando token: $e');
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Resultado del pago
class PaymentResult {
  final bool success;
  final String? paymentIntentId;
  final String? error;

  PaymentResult({required this.success, this.paymentIntentId, this.error});
}

class PaymentService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static const String stripePublishableKey =
      'pk_test_51SSPC9FQrDKWPh9Z7bF4MDXKsOdHnE3B7eiLaRTA6zc0e7Xol3uWynCNRb812WlIRFE4pw1XBN5nZEIjUtK8lWeZ008wTXSAAG';

  static const String backendUrl =
      'http://10.0.2.2:8080/api'; // Para emulador Android

  static PaymentService? _instance;
  static bool _isInitialized = false;

  factory PaymentService() {
    _instance ??= PaymentService._internal();
    return _instance!;
  }

  PaymentService._internal();

  /// Inicializar Stripe con la clave publicable (lazy initialization)
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      Stripe.publishableKey = stripePublishableKey;
      await Stripe.instance.applySettings();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error inicializando Stripe: $e');
      // No lanzar error - permitir que la app continúe
    }
  }

  /// Inicializar Stripe manualmente (opcional)
  Future<void> initialize() async {
    await _ensureInitialized();
  }

  /// Obtener token de autenticación
  Future<String?> _getAuthToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('Error obteniendo token: $e');
      return null;
    }
  }

  /// Crear Payment Intent en el backend
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Obtener token de autenticación
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      // Convertir amount a centavos (Stripe usa centavos)
      final amountInCents = (amount * 100).round();

      debugPrint('🔵 Creando Payment Intent...');
      debugPrint('   URL: $backendUrl/payments');
      debugPrint('   Amount (cents): $amountInCents');
      debugPrint('   Currency: $currency');

      final response = await http.post(
        Uri.parse('$backendUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'amount': amountInCents,
          'currency': currency,
          'orderId': orderId,
          'metadata': metadata ?? {},
        }),
      );

      debugPrint('📥 Respuesta del backend:');
      debugPrint('   Status Code: ${response.statusCode}');
      debugPrint('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Verificar si la respuesta tiene el formato correcto
        if (responseData['paymentIntentId'] != null &&
            responseData['clientSecret'] != null) {
          debugPrint('✅ Payment Intent creado exitosamente');
          debugPrint('   ID: ${responseData['paymentIntentId']}');
          return responseData;
        } else {
          throw Exception(
            'Respuesta inválida del servidor: falta paymentIntentId o clientSecret',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Token JWT inválido o expirado. Por favor, inicia sesión nuevamente.',
        );
      } else {
        final errorBody = response.body;
        debugPrint('❌ Error del backend: $errorBody');
        throw Exception(
          'Error al crear Payment Intent (${response.statusCode}): $errorBody',
        );
      }
    } catch (e) {
      debugPrint('❌ Error completo: $e');
      throw Exception('Error de red: $e');
    }
  }

  /// Procesar pago con tarjeta usando Payment Sheet
  Future<PaymentResult> processPaymentWithCard({
    required BuildContext context,
    required double amount,
    required String currency,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Asegurar que Stripe esté inicializado
      await _ensureInitialized();

      // 1. Crear Payment Intent en el backend
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        currency: currency,
        orderId: orderId,
        metadata: metadata,
      );

      final paymentIntentId = paymentIntentData['paymentIntentId'];

      // 2. Inicializar Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          merchantDisplayName: 'Reserva & Delivery',
          style: Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFFFF6B35), // AppTheme.primaryOrange
              background: Theme.of(context).scaffoldBackgroundColor,
            ),
            shapes: const PaymentSheetShape(borderRadius: 12),
          ),
        ),
      );

      // 3. Mostrar Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // Si llegamos aquí, el pago fue exitoso
      debugPrint('✅ Pago completado exitosamente');
      debugPrint('   Payment Intent ID: $paymentIntentId');

      return PaymentResult(success: true, paymentIntentId: paymentIntentId);
    } on StripeException catch (e) {
      // Errores específicos de Stripe
      debugPrint('❌ Error de Stripe: ${e.error.code}');
      debugPrint('   Mensaje: ${e.error.localizedMessage}');
      debugPrint('   Tipo: ${e.error.type}');

      // Si el usuario canceló el pago, no mostrar error
      if (e.error.code == FailureCode.Canceled) {
        debugPrint('ℹ️ Usuario canceló el pago');
        return PaymentResult(success: false, error: 'Pago cancelado');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.error.localizedMessage ?? 'Error al procesar el pago',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      return PaymentResult(
        success: false,
        error: e.error.localizedMessage ?? 'Error de Stripe',
      );
    } catch (e) {
      debugPrint('❌ Error inesperado al procesar pago: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error inesperado: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      return PaymentResult(success: false, error: e.toString());
    }
  }

  /// Procesar pago con Google Pay
  Future<bool> processPaymentWithGooglePay({
    required BuildContext context,
    required double amount,
    required String currency,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Asegurar que Stripe esté inicializado
      await _ensureInitialized();

      // 1. Crear Payment Intent
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        currency: currency,
        orderId: orderId,
        metadata: metadata,
      );

      // 2. Confirmar Google Pay payment
      await Stripe.instance.confirmPlatformPayPaymentIntent(
        clientSecret: paymentIntentData['clientSecret'],
        confirmParams: PlatformPayConfirmParams.googlePay(
          googlePay: GooglePayParams(
            merchantCountryCode: 'US',
            currencyCode: currency,
            testEnv: true, // Cambiar a false en producción
          ),
        ),
      );

      return true;
    } on StripeException catch (e) {
      debugPrint('Error de Google Pay: ${e.error.localizedMessage}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.error.localizedMessage ?? 'Error con Google Pay'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  /// Procesar pago con Apple Pay
  Future<bool> processPaymentWithApplePay({
    required BuildContext context,
    required double amount,
    required String currency,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Asegurar que Stripe esté inicializado
      await _ensureInitialized();

      // 1. Crear Payment Intent
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        currency: currency,
        orderId: orderId,
        metadata: metadata,
      );

      // 2. Confirmar Apple Pay payment
      await Stripe.instance.confirmPlatformPayPaymentIntent(
        clientSecret: paymentIntentData['clientSecret'],
        confirmParams: PlatformPayConfirmParams.applePay(
          applePay: ApplePayParams(
            merchantCountryCode: 'US',
            currencyCode: currency,
            cartItems: [
              ApplePayCartSummaryItem.immediate(
                label: 'Total',
                amount: amount.toStringAsFixed(2),
              ),
            ],
          ),
        ),
      );

      return true;
    } on StripeException catch (e) {
      debugPrint('Error de Apple Pay: ${e.error.localizedMessage}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.error.localizedMessage ?? 'Error con Apple Pay'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  /// Verificar si Google Pay está disponible
  Future<bool> isGooglePaySupported() async {
    try {
      return await Stripe.instance.isPlatformPaySupported(
        googlePay: const IsGooglePaySupportedParams(),
      );
    } catch (e) {
      return false;
    }
  }

  /// Verificar si Apple Pay está disponible
  Future<bool> isApplePaySupported() async {
    try {
      return await Stripe.instance.isPlatformPaySupported();
    } catch (e) {
      return false;
    }
  }
}

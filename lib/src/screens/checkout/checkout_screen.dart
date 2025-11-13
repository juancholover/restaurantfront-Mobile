import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../services/payment_service.dart';
import '../orders/order_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  String _paymentMethod = 'cash'; // cash, card, google_pay, apple_pay
  bool _isProcessing = false;
  bool _isGooglePayAvailable = false;
  bool _isApplePayAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkPlatformPayAvailability();
  }

  void _loadUserData() {
    // Cargar datos del usuario si existen
    // TODO: Implementar carga de direcciones guardadas
  }

  Future<void> _checkPlatformPayAvailability() async {
    final googlePaySupported = await _paymentService.isGooglePaySupported();
    final applePaySupported = await _paymentService.isApplePaySupported();

    setState(() {
      _isGooglePayAvailable = googlePaySupported;
      _isApplePayAvailable = applePaySupported;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (cart.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Pedido')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildOrderSummary(cart),
                  const SizedBox(height: 24),
                  _buildDeliveryInfo(),
                  const SizedBox(height: 24),
                  _buildPaymentMethod(),
                  const SizedBox(height: 24),
                  _buildSpecialInstructions(),
                ],
              ),
            ),
            _buildCheckoutButton(cart),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),

            // Productos
            ...cart.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.product.name}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 24),

            // Subtotal
            _buildPriceRow('Subtotal', cart.subtotal),
            const SizedBox(height: 8),
            _buildPriceRow('Envío', cart.deliveryFee),
            const SizedBox(height: 8),
            _buildPriceRow('Impuesto (10%)', cart.tax),
            const Divider(height: 24),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${cart.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Entrega',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Dirección
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección de entrega',
                hintText: 'Calle, número, ciudad',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una dirección';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Teléfono
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono de contacto',
                hintText: '+1 234 567 8900',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un teléfono';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Método de Pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Efectivo
            RadioListTile<String>(
              title: const Row(
                children: [
                  Icon(Icons.money, color: Colors.green),
                  SizedBox(width: 12),
                  Text('Efectivo'),
                ],
              ),
              subtitle: const Text('Pagar al recibir el pedido'),
              value: 'cash',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),

            // Tarjeta de crédito/débito (Stripe)
            RadioListTile<String>(
              title: const Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.blue),
                  SizedBox(width: 12),
                  Text('Tarjeta de Crédito/Débito'),
                ],
              ),
              subtitle: const Text(
                'Visa, Mastercard, Amex (Seguro con Stripe)',
              ),
              value: 'card',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),

            // Google Pay (solo si está disponible)
            if (_isGooglePayAvailable)
              RadioListTile<String>(
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        Icons.payment,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Google Pay'),
                  ],
                ),
                subtitle: const Text('Pago rápido y seguro'),
                value: 'google_pay',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),

            // Apple Pay (solo si está disponible)
            if (_isApplePayAvailable)
              RadioListTile<String>(
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.apple,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Apple Pay'),
                  ],
                ),
                subtitle: const Text('Pago rápido y seguro'),
                value: 'apple_pay',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),

            // Información de seguridad
            if (_paymentMethod == 'card' ||
                _paymentMethod == 'google_pay' ||
                _paymentMethod == 'apple_pay')
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pago 100% seguro procesado por Stripe',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instrucciones Especiales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                hintText: 'Ej: Sin cebolla, tocar el timbre, etc.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : () => _placeOrder(cart),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Realizar Pedido • \$${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder(CartProvider cart) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Si el método de pago requiere procesamiento en línea, procesar primero
      PaymentResult? paymentResult;
      String? paymentIntentId;

      if (_paymentMethod == 'card') {
        // Procesar pago con tarjeta usando Stripe
        paymentResult = await _paymentService.processPaymentWithCard(
          context: context,
          amount: cart.total,
          currency: 'usd',
          metadata: {
            'customer_name': _addressController.text,
            'phone': _phoneController.text,
          },
        );

        if (!paymentResult.success) {
          setState(() {
            _isProcessing = false;
          });
          return;
        }

        paymentIntentId = paymentResult.paymentIntentId;
      } else if (_paymentMethod == 'google_pay') {
        // Procesar con Google Pay (por ahora retorna bool, se actualizará después)
        final googlePaySuccess = await _paymentService
            .processPaymentWithGooglePay(
              context: context,
              amount: cart.total,
              currency: 'usd',
              metadata: {
                'customer_name': _addressController.text,
                'phone': _phoneController.text,
              },
            );

        if (!googlePaySuccess) {
          setState(() {
            _isProcessing = false;
          });
          return;
        }
      } else if (_paymentMethod == 'apple_pay') {
        // Procesar con Apple Pay (por ahora retorna bool, se actualizará después)
        final applePaySuccess = await _paymentService
            .processPaymentWithApplePay(
              context: context,
              amount: cart.total,
              currency: 'usd',
              metadata: {
                'customer_name': _addressController.text,
                'phone': _phoneController.text,
              },
            );

        if (!applePaySuccess) {
          setState(() {
            _isProcessing = false;
          });
          return;
        }
      }

      // Crear pedido en el backend
      final order = await _orderService.createOrder(
        restaurantId: cart.restaurantId!,
        items: cart.items
            .map(
              (item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
                'price': item.product.price,
              },
            )
            .toList(),
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        totalAmount: cart.total,
        deliveryAddress: _addressController.text,
        notes: _instructionsController.text.isNotEmpty
            ? _instructionsController.text
            : null,
        paymentMethod: _paymentMethod,
        paymentStatus: _paymentMethod == 'cash' ? 'pending' : 'completed',
        paymentIntentId: paymentIntentId, // ← Agregar Payment Intent ID
      );

      // Limpiar carrito
      await cart.clearCart();

      if (!mounted) return;

      debugPrint('✅ Orden creada exitosamente: #${order.id}');
      debugPrint('   Payment Intent ID: $paymentIntentId');

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Pedido #${order.id} realizado con éxito!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navegar a pantalla de detalles del pedido
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailScreen(orderId: order.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error al realizar el pedido: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

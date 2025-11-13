import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/review_service.dart';
import '../../services/share_service.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order/order_tracking_widget.dart';
import '../reviews/rate_order_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final ReviewService _reviewService = ReviewService();
  Order? _order;
  bool _isLoading = true;
  bool _hasReview = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() => _isLoading = true);

    try {
      final order = await _orderService.getOrderById(widget.orderId);

      // Verificar si el pedido ya tiene reseña
      final hasReview = await _reviewService.hasReviewForOrder(widget.orderId);

      if (mounted) {
        setState(() {
          _order = order;
          _hasReview = hasReview;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el pedido: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _loadOrderDetails,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusSection(),
                    const SizedBox(height: 24),
                    OrderTrackingWidget(
                      currentStatus: _order!.status,
                      estimatedDeliveryTime: _order!.estimatedDeliveryTime,
                    ),
                    const SizedBox(height: 24),
                    if (_order!.driver != null) ...[
                      _buildDriverInfo(),
                      const SizedBox(height: 24),
                    ],
                    _buildRestaurantInfo(),
                    const SizedBox(height: 24),
                    _buildOrderItems(),
                    const SizedBox(height: 24),
                    _buildDeliveryInfo(),
                    const SizedBox(height: 24),
                    _buildPriceSummary(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'No se pudo cargar el pedido',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadOrderDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusChip(_order!.status, large: true),
            const SizedBox(height: 16),
            if (_order!.estimatedDeliveryTime != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, color: AppTheme.primaryOrange),
                  const SizedBox(width: 8),
                  Text(
                    'Tiempo estimado: ${DateFormat('HH:mm').format(_order!.estimatedDeliveryTime!)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfo() {
    final driver = _order!.driver!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu Repartidor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryOrange,
                  backgroundImage: driver.photoUrl != null
                      ? NetworkImage(driver.photoUrl!)
                      : null,
                  child: driver.photoUrl == null
                      ? Text(
                          driver.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            driver.phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implementar llamada al repartidor
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función de llamada próximamente'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone, color: AppTheme.primaryOrange),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restaurante',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.restaurant, color: AppTheme.primaryOrange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _order!.restaurantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  'Pedido el ${DateFormat('dd MMM yyyy, HH:mm', 'es').format(_order!.createdAt)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._order!.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$${item.price.toStringAsFixed(2)} c/u',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
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
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: AppTheme.primaryOrange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _order!.deliveryAddress,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            if (_order!.specialInstructions != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instrucciones especiales:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _order!.specialInstructions!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Subtotal', _order!.subtotal),
            const SizedBox(height: 8),
            _buildPriceRow('Envío', _order!.deliveryFee),
            if (_order!.discount > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow('Descuento', -_order!.discount, isDiscount: true),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_order!.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pagado con ${_getPaymentMethodLabel(_order!.paymentMethod)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
        Text(
          '${isDiscount ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDiscount ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Efectivo';
      case 'card':
        return 'Tarjeta';
      case 'online':
        return 'Pago en Línea';
      default:
        return method;
    }
  }

  Widget _buildStatusChip(OrderStatus status, {bool large = false}) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        label = 'Pendiente';
        icon = Icons.schedule;
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        label = 'Confirmado';
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.preparing:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        label = 'Preparando';
        icon = Icons.restaurant_menu;
        break;
      case OrderStatus.ready:
        backgroundColor = Colors.teal.shade100;
        textColor = Colors.teal.shade900;
        label = 'Listo';
        icon = Icons.done_all;
        break;
      case OrderStatus.onTheWay:
        backgroundColor = Colors.indigo.shade100;
        textColor = Colors.indigo.shade900;
        label = 'En camino';
        icon = Icons.delivery_dining;
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        label = 'Entregado';
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        label = 'Cancelado';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 20 : 12,
        vertical: large ? 12 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(large ? 30 : 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: large ? 24 : 16, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: large ? 16 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.primaryOrange),
            SizedBox(width: 12),
            Text('Ayuda y Soporte'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Necesitas ayuda con tu pedido?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone, color: AppTheme.primaryOrange),
              title: const Text('Llamar a Soporte'),
              subtitle: const Text('+1 800 123 4567'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función de llamada próximamente'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppTheme.primaryOrange),
              title: const Text('Chat en Vivo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat próximamente')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canReview = _order!.status == OrderStatus.delivered && !_hasReview;

    return Column(
      children: [
        // Botón de Reordenar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _reorderItems(),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Volver a Pedir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Botón de Calificar (solo si está entregado y no ha sido calificado)
        if (canReview) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _rateOrder(),
              icon: const Icon(Icons.star_outline),
              label: const Text('Calificar Pedido'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppTheme.primaryOrange),
                foregroundColor: AppTheme.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],

        // Botón de Compartir
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _shareOrder(),
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _reorderItems() async {
    try {
      final cart = context.read<CartProvider>();

      // Verificar si hay items en el carrito
      if (cart.items.isNotEmpty) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Limpiar Carrito'),
            content: const Text(
              'Ya tienes productos en tu carrito. ¿Deseas reemplazarlos con este pedido?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                ),
                child: const Text('Reemplazar'),
              ),
            ],
          ),
        );

        if (confirm != true) return;
        await cart.clearCart();
      }

      // Agregar items del pedido al carrito
      // TODO: Necesitarás cargar los productos completos del restaurante
      // Para esto necesitas implementar la lógica de conversión

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ Productos agregados al carrito'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamed(context, '/cart');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rateOrder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RateOrderScreen(order: _order!)),
    );

    if (result == true && mounted) {
      // Recargar para actualizar el estado de la reseña
      _loadOrderDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ ¡Gracias por tu reseña!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _shareOrder() {
    ShareService.shareOrder(_order!);
  }
}

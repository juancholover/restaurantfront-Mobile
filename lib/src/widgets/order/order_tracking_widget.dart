import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';

/// Widget para mostrar el seguimiento visual del estado del pedido
class OrderTrackingWidget extends StatelessWidget {
  final OrderStatus currentStatus;
  final DateTime? estimatedDeliveryTime;

  const OrderTrackingWidget({
    super.key,
    required this.currentStatus,
    this.estimatedDeliveryTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estado del Pedido',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (estimatedDeliveryTime != null &&
                    currentStatus != OrderStatus.delivered &&
                    currentStatus != OrderStatus.cancelled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.primaryOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getEstimatedTime(),
                          style: const TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTimelineSteps(),
          ],
        ),
      ),
    );
  }

  String _getEstimatedTime() {
    if (estimatedDeliveryTime == null) return '';

    final now = DateTime.now();
    final difference = estimatedDeliveryTime!.difference(now);

    if (difference.isNegative) return 'Próximamente';

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    }
  }

  Widget _buildTimelineSteps() {
    final steps = _getOrderSteps();

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return _buildTimelineStep(step: step, isLast: isLast);
      }),
    );
  }

  List<_OrderStep> _getOrderSteps() {
    if (currentStatus == OrderStatus.cancelled) {
      return [
        _OrderStep(
          status: OrderStatus.cancelled,
          title: 'Pedido Cancelado',
          subtitle: 'Tu pedido ha sido cancelado',
          icon: Icons.cancel,
          isCompleted: true,
          isActive: true,
        ),
      ];
    }

    return [
      _OrderStep(
        status: OrderStatus.pending,
        title: 'Pedido Recibido',
        subtitle: 'Esperando confirmación',
        icon: Icons.receipt_long,
        isCompleted: _isStatusCompleted(OrderStatus.pending),
        isActive: currentStatus == OrderStatus.pending,
      ),
      _OrderStep(
        status: OrderStatus.confirmed,
        title: 'Confirmado',
        subtitle: 'El restaurante ha aceptado tu pedido',
        icon: Icons.check_circle_outline,
        isCompleted: _isStatusCompleted(OrderStatus.confirmed),
        isActive: currentStatus == OrderStatus.confirmed,
      ),
      _OrderStep(
        status: OrderStatus.preparing,
        title: 'En Preparación',
        subtitle: 'Tu pedido se está preparando',
        icon: Icons.restaurant_menu,
        isCompleted: _isStatusCompleted(OrderStatus.preparing),
        isActive: currentStatus == OrderStatus.preparing,
      ),
      _OrderStep(
        status: OrderStatus.ready,
        title: 'Listo para Entrega',
        subtitle: 'Esperando al repartidor',
        icon: Icons.done_all,
        isCompleted: _isStatusCompleted(OrderStatus.ready),
        isActive: currentStatus == OrderStatus.ready,
      ),
      _OrderStep(
        status: OrderStatus.onTheWay,
        title: 'En Camino',
        subtitle: 'El repartidor va hacia ti',
        icon: Icons.delivery_dining,
        isCompleted: _isStatusCompleted(OrderStatus.onTheWay),
        isActive: currentStatus == OrderStatus.onTheWay,
      ),
      _OrderStep(
        status: OrderStatus.delivered,
        title: 'Entregado',
        subtitle: '¡Disfruta tu pedido!',
        icon: Icons.check_circle,
        isCompleted: currentStatus == OrderStatus.delivered,
        isActive: currentStatus == OrderStatus.delivered,
      ),
    ];
  }

  bool _isStatusCompleted(OrderStatus status) {
    final statusOrder = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];

    final currentIndex = statusOrder.indexOf(currentStatus);
    final stepIndex = statusOrder.indexOf(status);

    return stepIndex < currentIndex ||
        (stepIndex == currentIndex && currentStatus == OrderStatus.delivered);
  }

  Widget _buildTimelineStep({required _OrderStep step, required bool isLast}) {
    final iconColor = step.isCompleted || step.isActive
        ? AppTheme.primaryOrange
        : Colors.grey.shade400;

    final lineColor = step.isCompleted
        ? AppTheme.primaryOrange
        : Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: step.isCompleted || step.isActive
                    ? AppTheme.primaryOrange.withOpacity(0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: iconColor, width: 2),
              ),
              child: Icon(step.icon, size: 20, color: iconColor),
            ),
            if (!isLast) Container(width: 2, height: 50, color: lineColor),
          ],
        ),
        const SizedBox(width: 16),
        // Step content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: step.isActive || step.isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: step.isActive || step.isCompleted
                        ? Colors.black87
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                if (step.isActive && step.status != OrderStatus.delivered)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation(
                              AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'En proceso...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryOrange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderStep {
  final OrderStatus status;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;

  _OrderStep({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.isActive,
  });
}

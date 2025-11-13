import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget para mostrar un cupón disponible
class CouponCard extends StatelessWidget {
  final Map<String, dynamic> couponData;
  final VoidCallback? onTap;
  final bool showCopyButton;

  const CouponCard({
    super.key,
    required this.couponData,
    this.onTap,
    this.showCopyButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPercentage = couponData['discountType'] == 'PERCENTAGE';
    final discountValue = couponData['discountValue'];
    final code = couponData['code'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.orange.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con código y descuento
              Row(
                children: [
                  // Código del cupón
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange,
                                letterSpacing: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Badge de descuento
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPercentage ? '-$discountValue%' : '-S/$discountValue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Botón copiar
                  if (showCopyButton)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      color: Colors.grey[600],
                      onPressed: () => _copyCouponCode(context, code),
                      tooltip: 'Copiar código',
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Descripción
              Text(
                couponData['description'],
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Info adicional
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.shopping_cart,
                    label: 'Mínimo: S/${couponData['minimumAmount']}',
                    color: Colors.blue,
                  ),
                  if (couponData['maximumDiscount'] != null)
                    _buildInfoChip(
                      icon: Icons.discount,
                      label: 'Máx: S/${couponData['maximumDiscount']}',
                      color: Colors.purple,
                    ),
                  _buildInfoChip(
                    icon: Icons.calendar_today,
                    label: 'Hasta ${_formatDate(couponData['expiresAt'])}',
                    color: Colors.orange,
                  ),
                ],
              ),

              // Usos disponibles
              if (couponData['usageLimit'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${couponData['usageLimit'] - couponData['usageCount']} usos disponibles',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '';
    }
  }

  void _copyCouponCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Código "$code" copiado'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

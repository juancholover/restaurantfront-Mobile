import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/review_service.dart';
import '../../theme/app_theme.dart';

class RateOrderScreen extends StatefulWidget {
  final Order order;

  const RateOrderScreen({super.key, required this.order});

  @override
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe un comentario'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _reviewService.createReview(
        orderId: widget.order.id,
        restaurantId: widget.order.restaurantId,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('✨ ¡Gracias por tu reseña!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calificar Pedido')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del restaurante
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.restaurant,
                      size: 40,
                      color: AppTheme.primaryOrange,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.order.restaurantName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pedido #${widget.order.id}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Calificación con estrellas
            const Text(
              '¿Cómo estuvo tu pedido?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        iconSize: 48,
                        onPressed: () {
                          setState(() {
                            _rating = (index + 1).toDouble();
                          });
                        },
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber[700],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRatingText(_rating),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Comentario
            const Text(
              'Cuéntanos tu experiencia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText:
                    'Describe cómo estuvo la comida, el servicio, la presentación...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryOrange,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sugerencias rápidas
            const Text(
              'Aspectos a calificar:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSuggestionChip('🍕 Sabor'),
                _buildSuggestionChip('🔥 Temperatura'),
                _buildSuggestionChip('📦 Presentación'),
                _buildSuggestionChip('⏰ Puntualidad'),
                _buildSuggestionChip('💰 Precio'),
                _buildSuggestionChip('🚚 Empaque'),
              ],
            ),
            const SizedBox(height: 32),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Enviar Reseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        final current = _commentController.text;
        if (current.isEmpty) {
          _commentController.text = label;
        } else {
          _commentController.text = '$current, $label';
        }
      },
      backgroundColor: Colors.grey[100],
    );
  }

  String _getRatingText(double rating) {
    if (rating <= 1) return 'Muy malo 😞';
    if (rating <= 2) return 'Malo 😕';
    if (rating <= 3) return 'Regular 😐';
    if (rating <= 4) return 'Bueno 😊';
    return 'Excelente! 🤩';
  }
}

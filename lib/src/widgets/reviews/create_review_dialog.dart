import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import '../../services/review_service.dart';

class CreateReviewDialog extends StatefulWidget {
  final Restaurant restaurant;
  final VoidCallback onReviewCreated;

  const CreateReviewDialog({
    super.key,
    required this.restaurant,
    required this.onReviewCreated,
  });

  @override
  State<CreateReviewDialog> createState() => _CreateReviewDialogState();
}

class _CreateReviewDialogState extends State<CreateReviewDialog> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;
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
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // orderId es null porque es una reseña general (no asociada a un pedido)
      await _reviewService.createReview(
        orderId: null, // Reseña sin pedido asociado
        restaurantId: widget.restaurant.id,
        restaurantName:
            widget.restaurant.name, // Enviar el nombre del restaurante
        rating: _rating.toDouble(),
        comment: _commentController.text.trim(),
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onReviewCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reseña publicada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                children: [
                  const Icon(Icons.rate_review, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Escribe tu reseña',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.restaurant.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calificación
              const Text(
                'Calificación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Campo de comentario
              const Text(
                'Tu experiencia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: '¿Qué te pareció este restaurante?',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.orange,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                              'Publicar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

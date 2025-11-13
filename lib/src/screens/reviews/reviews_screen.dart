import 'package:flutter/material.dart';
import '../../models/review.dart';
import '../../models/restaurant.dart';
import '../../services/review_service.dart';
import '../../widgets/reviews/create_review_dialog.dart';

class ReviewsScreen extends StatefulWidget {
  final Restaurant restaurant;

  const ReviewsScreen({super.key, required this.restaurant});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    final reviews = await _reviewService.getRestaurantReviews(
      widget.restaurant.id,
    );
    setState(() {
      _reviews = reviews;
      _isLoading = false;
    });
  }

  void _showCreateReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateReviewDialog(
        restaurant: widget.restaurant,
        onReviewCreated: () {
          _loadReviews();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reseñas de ${widget.restaurant.name}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white, // Color blanco para el texto y la flecha
        iconTheme: const IconThemeData(color: Colors.white), // Flecha blanca
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
          ? _buildEmptyState()
          : _buildReviewsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateReviewDialog,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.rate_review),
        label: const Text('Escribir reseña'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aún no hay reseñas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Sé el primero en escribir una!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateReviewDialog,
            icon: const Icon(Icons.edit),
            label: const Text('Escribir primera reseña'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return RefreshIndicator(
      onRefresh: _loadReviews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return _buildReviewCard(review);
        },
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Usuario y fecha
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 20,
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatDate(review.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStarRating(review.rating.round()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Comentario
            Text(
              review.comment,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace ${weeks == 1 ? '1 semana' : '$weeks semanas'}';
    } else {
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
    }
  }
}

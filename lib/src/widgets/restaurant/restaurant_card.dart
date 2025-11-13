import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../providers/favorites_provider.dart';
import '../../screens/restaurants/restaurant_detail_screen.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool isListView;
  final VoidCallback? onFavoriteToggle;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.isListView = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantDetailScreen(restaurant: restaurant),
            ),
          );
        },
        child: isListView ? _buildListLayout() : _buildGridLayout(),
      ),
    );
  }

  Widget _buildGridLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Imagen
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                restaurant.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, size: 50),
                  );
                },
              ),
            ),
            // Favorito
            Positioned(top: 8, right: 8, child: _buildFavoriteButton()),
            // Badge de promoción
            if (restaurant.hasPromotion)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${restaurant.discountPercentage ?? 0}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // Badge abierto/cerrado
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: restaurant.isOpenNow ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  restaurant.isOpenNow ? 'Abierto' : 'Cerrado',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Info
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                restaurant.description,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 13),
                  const SizedBox(width: 2),
                  Text(
                    restaurant.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  // Cantidad de reseñas
                  if (restaurant.reviewCount > 0) ...[
                    const SizedBox(width: 2),
                    Text(
                      '(${restaurant.reviewCount})',
                      style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                    ),
                  ],
                  const Spacer(),
                  // Rango de precios
                  Text(
                    restaurant.priceRange,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 2),
                  Text(
                    '${restaurant.deliveryTime} min',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  // Distancia (si está disponible)
                  if (restaurant.distanceKm != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text(
                      '${restaurant.distanceKm!.toStringAsFixed(1)} km',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListLayout() {
    return Row(
      children: [
        // Imagen
        Stack(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Image.network(
                restaurant.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, size: 40),
                  );
                },
              ),
            ),
            // Promoción
            if (restaurant.hasPromotion)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${restaurant.discountPercentage}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // Envío gratis
            if (restaurant.deliveryFee == 0)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Gratis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // Abierto/Cerrado
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: restaurant.isOpenNow ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  restaurant.isOpenNow ? '●' : '●',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildFavoriteButton(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (restaurant.reviewCount > 0) ...[
                      const SizedBox(width: 2),
                      Text(
                        '(${restaurant.reviewCount})',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(width: 8),
                    // Rango de precios
                    Text(
                      restaurant.priceRange,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${restaurant.deliveryTime} min',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    if (restaurant.distanceKm != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.distanceKm!.toStringAsFixed(1)} km',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(width: 12),
                    Icon(
                      Icons.delivery_dining,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${restaurant.deliveryFee.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(restaurant.id);

        return GestureDetector(
          onTap: onFavoriteToggle,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}

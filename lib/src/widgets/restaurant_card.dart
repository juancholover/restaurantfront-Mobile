import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../providers/favorites_provider.dart';
import '../services/share_service.dart';
import '../utils/opening_hours_helper.dart';
import '../theme/app_theme.dart';
import '../screens/restaurants/restaurant_detail_screen.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool showFavoriteButton;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del restaurante
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    restaurant.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.restaurant,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                // Botón de favorito
                if (showFavoriteButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<FavoritesProvider>(
                      builder: (context, favorites, _) {
                        final isFavorite = favorites.isFavorite(restaurant.id);
                        return Material(
                          color: Colors.white,
                          elevation: 4,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () async {
                              await favorites.toggleFavorite(restaurant);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isFavorite
                                          ? '💔 Eliminado de favoritos'
                                          : '❤️ Agregado a favoritos',
                                    ),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: isFavorite
                                        ? Colors.grey[700]
                                        : AppTheme.primaryOrange,
                                  ),
                                );
                              }
                            },
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? Colors.red
                                    : Colors.grey[700],
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Badge de estado (abierto/cerrado)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Builder(
                    builder: (context) {
                      final status = OpeningHoursHelper.getOpenStatus(
                        restaurant.openingHours,
                      );
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: status['color'] as Color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              status['isOpen'] as bool
                                  ? Icons.access_time
                                  : Icons.access_time_filled,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status['text'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Información del restaurante
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Categoría
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.categories.isNotEmpty
                              ? restaurant.categories.join(', ')
                              : 'Sin categoría',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating, tiempo y costo de envío
                  Row(
                    children: [
                      // Rating
                      Icon(Icons.star, size: 16, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Tiempo de entrega
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.deliveryTime} min',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),

                      // Costo de envío
                      const Icon(
                        Icons.delivery_dining,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.deliveryFee > 0
                            ? '\$${restaurant.deliveryFee.toStringAsFixed(2)}'
                            : 'Gratis',
                        style: TextStyle(
                          fontSize: 14,
                          color: restaurant.deliveryFee > 0
                              ? Colors.grey[600]
                              : Colors.green,
                          fontWeight: restaurant.deliveryFee > 0
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),

                      // Precio promedio (si está disponible)
                      if (restaurant.averagePrice != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        Text(
                          '\$${restaurant.averagePrice!.toStringAsFixed(0)} promedio',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Botón de compartir
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ShareService.shareRestaurant(restaurant);
                      },
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Compartir'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(color: Colors.grey.shade300),
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
}

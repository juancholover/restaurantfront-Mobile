import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/restaurant/restaurant_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favorites, _) {
              if (favorites.favorites.isEmpty) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Limpiar favoritos',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Limpiar Favoritos'),
                      content: const Text(
                        '¿Estás seguro de que deseas eliminar todos tus restaurantes favoritos?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Eliminar Todos'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await favorites.clearFavorites();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Favoritos eliminados'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer2<FavoritesProvider, RestaurantProvider>(
        builder: (context, favoritesProvider, restaurantProvider, _) {
          // Obtener los restaurantes favoritos con datos completos
          final favoriteRestaurants = restaurantProvider.restaurants
              .where((r) => favoritesProvider.isFavorite(r.id))
              .toList();

          if (favoriteRestaurants.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await restaurantProvider.fetchRestaurants();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = favoriteRestaurants[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RestaurantCard(
                    restaurant: restaurant,
                    isListView: true,
                    onFavoriteToggle: () {
                      favoritesProvider.toggleFavorite(restaurant);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            'Aún no tienes favoritos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Guarda tus restaurantes favoritos\npara acceder a ellos rápidamente',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/restaurants');
            },
            icon: const Icon(Icons.restaurant),
            label: const Text('Explorar Restaurantes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

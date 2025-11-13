import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/restaurant/restaurant_card.dart';
import '../../widgets/restaurant/category_chips.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../theme/app_theme.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // Cargar restaurantes al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().fetchRestaurants();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/map');
        },
        label: const Text('Ver en mapa'),
        icon: const Icon(Icons.map_outlined),
        backgroundColor: AppTheme.primaryOrange,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            // Search Bar
            _buildSearchBar(),

            const SizedBox(height: 16),

            // Category Chips
            const CategoryChips(),

            const SizedBox(height: 16),

            // Filters & View Toggle
            _buildFiltersBar(),

            const SizedBox(height: 8),

            // Restaurant List/Grid
            Expanded(
              child: Consumer<RestaurantProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const LoadingWidget();
                  }

                  if (provider.error != null) {
                    return CustomErrorWidget(
                      message: provider.error!,
                      onRetry: () => provider.fetchRestaurants(),
                    );
                  }

                  if (!provider.hasRestaurants) {
                    return EmptyState(
                      icon: Icons.restaurant,
                      title: 'No hay restaurantes',
                      message: 'No encontramos restaurantes con estos filtros',
                      actionLabel: 'Limpiar filtros',
                      onAction: () => provider.clearFilters(),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.refresh(),
                    child: _isGridView
                        ? _buildGridView(provider)
                        : _buildListView(provider),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              children: const [
                TextSpan(text: 'Explora\n'),
                TextSpan(
                  text: 'Restaurantes',
                  style: TextStyle(color: AppTheme.primaryOrange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<RestaurantProvider>().searchRestaurants(value);
        },
        decoration: InputDecoration(
          hintText: 'Buscar restaurantes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<RestaurantProvider>().searchRestaurants('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Sort Button
          _buildSortButton(),
          const Spacer(),
          // View Toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.sort, size: 20),
            SizedBox(width: 8),
            Text('Ordenar'),
          ],
        ),
      ),
      onSelected: (value) {
        final provider = context.read<RestaurantProvider>();
        switch (value) {
          case 'rating':
            provider.sortByRating();
            break;
          case 'time':
            provider.sortByDeliveryTime();
            break;
          case 'name':
            provider.sortByName();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'rating', child: Text('Mejor calificación')),
        const PopupMenuItem(value: 'time', child: Text('Tiempo de entrega')),
        const PopupMenuItem(value: 'name', child: Text('Nombre A-Z')),
      ],
    );
  }

  Widget _buildGridView(RestaurantProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9, // Ajustado para Chrome - más alto
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = provider.restaurants[index];
        return RestaurantCard(
          restaurant: restaurant,
          onFavoriteToggle: () {
            context.read<FavoritesProvider>().toggleFavorite(restaurant);
          },
        );
      },
    );
  }

  Widget _buildListView(RestaurantProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = provider.restaurants[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RestaurantCard(
            restaurant: restaurant,
            isListView: true,
            onFavoriteToggle: () {
              context.read<FavoritesProvider>().toggleFavorite(restaurant);
            },
          ),
        );
      },
    );
  }
}

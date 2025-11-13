import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';

class RestaurantProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Getters
  List<Restaurant> get restaurants => _filteredRestaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get hasRestaurants => _filteredRestaurants.isNotEmpty;

  // Categorías disponibles
  List<String> get categories => [
    'All',
    'Pizza',
    'Burger',
    'Asian',
    'Mexican',
    'Italian',
    'Desserts',
    'Healthy',
  ];

  // Fetch restaurants from API
  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/restaurants');

      if (response['success'] == true) {
        _restaurants = (response['data'] as List)
            .map((json) => Restaurant.fromJson(json))
            .map((restaurant) {
              // Siempre inferir categorías si solo tiene "Restaurant" genérico
              if (restaurant.categories.isEmpty ||
                  restaurant.categories.length == 1 &&
                      restaurant.categories[0] == 'Restaurant') {
                debugPrint('⚠️ Categorías genéricas o vacías, infiriendo...');
                return restaurant.copyWith(
                  categories: _inferCategories(restaurant),
                );
              }
              debugPrint('✅ Categorías del backend: ${restaurant.categories}');
              return restaurant;
            })
            .toList();
        _filteredRestaurants = List.from(_restaurants);
      } else {
        _error = response['message'] ?? 'Error al cargar restaurantes';
      }
    } catch (e) {
      debugPrint('Error fetching restaurants: $e');
      _error = 'Error de conexión con el backend: ${e.toString()}';
      _restaurants = [];
      _filteredRestaurants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Inferir categorías del nombre o descripción del restaurante
  List<String> _inferCategories(Restaurant restaurant) {
    final text = '${restaurant.name} ${restaurant.description}'.toLowerCase();
    final categories = <String>[];

    debugPrint('🔍 Infiriendo categorías para: ${restaurant.name}');
    debugPrint('   Texto a analizar: $text');

    if (text.contains('pizza')) {
      categories.add('Pizza');
      debugPrint('   ✅ Detectado: Pizza');
    }
    if (text.contains('burger') || text.contains('hamburgues')) {
      categories.add('Burger');
      debugPrint('   ✅ Detectado: Burger');
    }
    if (text.contains('asian') ||
        text.contains('sushi') ||
        text.contains('wok') ||
        text.contains('china') ||
        text.contains('japonés') ||
        text.contains('japones')) {
      categories.add('Asian');
      debugPrint('   ✅ Detectado: Asian');
    }
    if (text.contains('mexican') ||
        text.contains('taco') ||
        text.contains('burrito')) {
      categories.add('Mexican');
      debugPrint('   ✅ Detectado: Mexican');
    }
    if (text.contains('italian') ||
        text.contains('pasta') ||
        text.contains('italiano')) {
      categories.add('Italian');
      debugPrint('   ✅ Detectado: Italian');
    }
    if (text.contains('dessert') ||
        text.contains('postre') ||
        text.contains('helado') ||
        text.contains('ice cream')) {
      categories.add('Desserts');
      debugPrint('   ✅ Detectado: Desserts');
    }
    if (text.contains('health') ||
        text.contains('ensalada') ||
        text.contains('salad') ||
        text.contains('vegano') ||
        text.contains('vegan')) {
      categories.add('Healthy');
      debugPrint('   ✅ Detectado: Healthy');
    }

    debugPrint('   📋 Categorías finales: $categories');
    return categories;
  }

  // Búsqueda
  void searchRestaurants(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Filtrar por categoría
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Aplicar filtros
  void _applyFilters() {
    _filteredRestaurants = _restaurants.where((restaurant) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          restaurant.name.toLowerCase().contains(_searchQuery) ||
          restaurant.description.toLowerCase().contains(_searchQuery);

      final matchesCategory =
          _selectedCategory == 'All' ||
          restaurant.categories.contains(_selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();

    notifyListeners();
  }

  // Ordenar por rating
  void sortByRating() {
    _filteredRestaurants.sort((a, b) => b.rating.compareTo(a.rating));
    notifyListeners();
  }

  // Ordenar por tiempo de entrega
  void sortByDeliveryTime() {
    _filteredRestaurants.sort(
      (a, b) => a.deliveryTime.compareTo(b.deliveryTime),
    );
    notifyListeners();
  }

  // Ordenar por nombre
  void sortByName() {
    _filteredRestaurants.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  // Toggle favorito
  void toggleFavorite(int restaurantId) {
    final index = _restaurants.indexWhere((r) => r.id == restaurantId);
    if (index != -1) {
      _restaurants[index] = _restaurants[index].copyWith(
        isFavorite: !_restaurants[index].isFavorite,
      );
      _applyFilters();
    }
  }

  // Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _filteredRestaurants = List.from(_restaurants);
    notifyListeners();
  }

  // Refresh
  Future<void> refresh() async {
    await fetchRestaurants();
  }
}

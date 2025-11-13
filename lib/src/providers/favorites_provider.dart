import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/restaurant.dart';

class FavoritesProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  static const _favoritesKey = 'favorite_restaurants';

  List<int> _favoriteIds = [];
  final Map<int, Restaurant> _favoriteRestaurants = {};

  List<int> get favoriteIds => _favoriteIds;
  List<Restaurant> get favorites => _favoriteRestaurants.values.toList();

  bool isFavorite(int restaurantId) {
    return _favoriteIds.contains(restaurantId);
  }

  Future<void> loadFavorites() async {
    try {
      final favoritesJson = await _storage.read(key: _favoritesKey);
      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favoriteIds = decoded.cast<int>();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final favoritesJson = json.encode(_favoriteIds);
      await _storage.write(key: _favoritesKey, value: favoritesJson);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  Future<void> toggleFavorite(Restaurant restaurant) async {
    if (_favoriteIds.contains(restaurant.id)) {
      // Remover de favoritos
      _favoriteIds.remove(restaurant.id);
      _favoriteRestaurants.remove(restaurant.id);
      debugPrint('❌ Restaurante ${restaurant.name} removido de favoritos');
    } else {
      // Agregar a favoritos
      _favoriteIds.add(restaurant.id);
      _favoriteRestaurants[restaurant.id] = restaurant;
      debugPrint('✅ Restaurante ${restaurant.name} agregado a favoritos');
    }

    await _saveFavorites();
    notifyListeners();
  }

  void updateRestaurantData(Restaurant restaurant) {
    if (_favoriteIds.contains(restaurant.id)) {
      _favoriteRestaurants[restaurant.id] = restaurant;
      notifyListeners();
    }
  }

  Future<void> clearFavorites() async {
    _favoriteIds.clear();
    _favoriteRestaurants.clear();
    await _storage.delete(key: _favoritesKey);
    notifyListeners();
  }
}

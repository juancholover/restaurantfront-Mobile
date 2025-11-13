import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/restaurant.dart';
import '../../providers/restaurant_provider.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import 'restaurant_detail_screen.dart';

class RestaurantMapScreen extends StatefulWidget {
  const RestaurantMapScreen({super.key});

  @override
  State<RestaurantMapScreen> createState() => _RestaurantMapScreenState();
}

class _RestaurantMapScreenState extends State<RestaurantMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _locationService = LocationService();

  Set<Marker> _markers = {};
  Set<Circle> _circles = {}; // Círculo para ubicación actual
  Restaurant? _selectedRestaurant;
  LatLng? _currentPosition;
  bool _isLoading = true;
  bool _isLocationSimulated = false; // Indicador de ubicación simulada

  // Universidad Peruana Unión, Lima, Perú por defecto
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(-12.0431, -76.9582), // UPeU
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);

    try {
      // Obtener ubicación actual
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        // Si el emulador da ubicación fuera de Perú, usar UPeU Lima
        if (position.latitude < -20 ||
            position.latitude > 0 ||
            position.longitude < -85 ||
            position.longitude > -68) {
          print(
            '⚠️ Ubicación fuera de Perú, usando UPeU Lima como ubicación actual',
          );
          _currentPosition = const LatLng(-12.0431, -76.9582); // UPeU
          _isLocationSimulated = true;
        } else {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLocationSimulated = false;
        }
      } else {
        // Sin ubicación, usar UPeU por defecto
        _currentPosition = const LatLng(-12.0431, -76.9582);
        _isLocationSimulated = true;
        print('📍 Sin ubicación GPS, usando UPeU Lima por defecto');
      }

      // Cargar restaurantes y crear marcadores
      if (mounted) {
        final restaurantProvider = Provider.of<RestaurantProvider>(
          context,
          listen: false,
        );
        await restaurantProvider.fetchRestaurants();

        print(
          '🗺️ Restaurantes cargados: ${restaurantProvider.restaurants.length}',
        );
        for (var r in restaurantProvider.restaurants) {
          print('📍 ${r.name}: lat=${r.latitude}, lng=${r.longitude}');
        }

        _createMarkers(restaurantProvider.restaurants);

        setState(() => _isLoading = false);

        // Ajustar cámara para mostrar todos los restaurantes
        await _fitMapToShowAllMarkers(restaurantProvider.restaurants);
      }
    } catch (e) {
      print('❌ Error inicializando mapa: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el mapa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _createMarkers(List<Restaurant> restaurants) {
    final Set<Marker> markers = {};
    final Set<Circle> circles = {};
    int validRestaurants = 0;

    // Marcador y círculo de ubicación actual
    if (_currentPosition != null) {
      // Marcador azul
      markers.add(
        Marker(
          markerId: const MarkerId('my_location'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: '📍 Tú estás aquí',
            snippet:
                'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}',
          ),
          anchor: const Offset(0.5, 0.5),
        ),
      );

      // Círculo azul semi-transparente alrededor de tu ubicación
      circles.add(
        Circle(
          circleId: const CircleId('my_location_circle'),
          center: _currentPosition!,
          radius: 500, // 500 metros
          fillColor: Colors.blue.withOpacity(0.15),
          strokeColor: Colors.blue.withOpacity(0.5),
          strokeWidth: 2,
        ),
      );

      print(
        '📍 Marcador de ubicación agregado: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
      );
    }

    // Marcadores de restaurantes
    for (var restaurant in restaurants) {
      if (restaurant.latitude != 0 && restaurant.longitude != 0) {
        markers.add(
          Marker(
            markerId: MarkerId(restaurant.id.toString()),
            position: LatLng(restaurant.latitude, restaurant.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              restaurant.isActive
                  ? BitmapDescriptor.hueOrange
                  : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: restaurant.name,
              snippet:
                  '⭐ ${restaurant.rating} | ${restaurant.deliveryTime} min',
            ),
            onTap: () => _onRestaurantTapped(restaurant),
          ),
        );
        validRestaurants++;
        print(
          '🍔 Marcador agregado: ${restaurant.name} en ${restaurant.latitude}, ${restaurant.longitude}',
        );
      } else {
        print('⚠️  Restaurante sin coordenadas: ${restaurant.name}');
      }
    }

    print(
      '✅ Total marcadores creados: ${markers.length} ($validRestaurants restaurantes + ${_currentPosition != null ? 1 : 0} ubicación)',
    );

    setState(() {
      _markers = markers;
      _circles = circles;
    });
  }

  void _onRestaurantTapped(Restaurant restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
    });

    // Mover cámara al restaurante
    _moveCamera(LatLng(restaurant.latitude, restaurant.longitude), zoom: 15);
  }

  Future<void> _moveCamera(LatLng position, {double zoom = 14}) async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom),
      ),
    );
  }

  // Ajustar el mapa para mostrar todos los restaurantes
  Future<void> _fitMapToShowAllMarkers(List<Restaurant> restaurants) async {
    if (restaurants.isEmpty) return;

    // Filtrar restaurantes con coordenadas válidas
    final validRestaurants = restaurants
        .where((r) => r.latitude != 0 && r.longitude != 0)
        .toList();

    if (validRestaurants.isEmpty) return;

    // Calcular límites
    double minLat = validRestaurants.first.latitude;
    double maxLat = validRestaurants.first.latitude;
    double minLng = validRestaurants.first.longitude;
    double maxLng = validRestaurants.first.longitude;

    for (var restaurant in validRestaurants) {
      if (restaurant.latitude < minLat) minLat = restaurant.latitude;
      if (restaurant.latitude > maxLat) maxLat = restaurant.latitude;
      if (restaurant.longitude < minLng) minLng = restaurant.longitude;
      if (restaurant.longitude > maxLng) maxLng = restaurant.longitude;
    }

    // Incluir ubicación actual si existe
    if (_currentPosition != null) {
      if (_currentPosition!.latitude < minLat) {
        minLat = _currentPosition!.latitude;
      }
      if (_currentPosition!.latitude > maxLat) {
        maxLat = _currentPosition!.latitude;
      }
      if (_currentPosition!.longitude < minLng) {
        minLng = _currentPosition!.longitude;
      }
      if (_currentPosition!.longitude > maxLng) {
        maxLng = _currentPosition!.longitude;
      }
    }

    // Crear límites con padding
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50), // 50 pixels de padding
    );
  }

  Future<void> _goToMyLocation() async {
    if (_currentPosition != null) {
      _moveCamera(_currentPosition!, zoom: 15);
    } else {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        final myLocation = LatLng(position.latitude, position.longitude);
        setState(() => _currentPosition = myLocation);
        _moveCamera(myLocation, zoom: 15);

        // Actualizar marcador
        _createMarkers(
          Provider.of<RestaurantProvider>(context, listen: false).restaurants,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantCount =
        _markers.length - (_currentPosition != null ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mapa de Restaurantes'),
            if (restaurantCount > 0)
              Text(
                '$restaurantCount restaurante${restaurantCount != 1 ? 's' : ''} cerca',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToMyLocation,
            tooltip: 'Mi ubicación',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeMap,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa
          GoogleMap(
            initialCameraPosition: _defaultPosition,
            markers: _markers,
            circles: _circles, // Agregar círculos
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: true, // Activar controles de zoom
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (_) {
              setState(() => _selectedRestaurant = null);
            },
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Banner de ubicación simulada
          if (_isLocationSimulated && !_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.blue.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Ubicación simulada en UPeU - Lima (emulador)',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() => _isLocationSimulated = false);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Tarjeta de restaurante seleccionado
          if (_selectedRestaurant != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildRestaurantCard(_selectedRestaurant!),
            ),

          // Botones flotantes
          Positioned(
            right: 16,
            bottom: _selectedRestaurant != null ? 260 : 140,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón: Ver todos los restaurantes
                FloatingActionButton(
                  heroTag: 'fit_all',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    final restaurants = Provider.of<RestaurantProvider>(
                      context,
                      listen: false,
                    ).restaurants;
                    await _fitMapToShowAllMarkers(restaurants);
                  },
                  tooltip: 'Ver todos',
                  child: const Icon(
                    Icons.zoom_out_map,
                    color: AppTheme.primaryOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                // Botón: Mi ubicación
                FloatingActionButton(
                  heroTag: 'my_location',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _goToMyLocation,
                  tooltip: 'Mi ubicación',
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                // Botón: Vista lista
                FloatingActionButton(
                  heroTag: 'list_view',
                  backgroundColor: AppTheme.primaryOrange,
                  onPressed: () {
                    // Volver a la pantalla anterior (RestaurantsScreen)
                    Navigator.of(context).pop();
                  },
                  tooltip: 'Restaurantes',
                  child: const Icon(Icons.restaurant_menu, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    String? distanceText;
    if (_currentPosition != null) {
      final distance = _locationService.getDistanceFromCurrent(
        latitude: restaurant.latitude,
        longitude: restaurant.longitude,
      );
      if (distance != null) {
        distanceText = _locationService.formatDistance(distance);
      }
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navegar directamente al detalle del restaurante para ver el menú
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantDetailScreen(restaurant: restaurant),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Ver Menú',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.address,
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
                    onPressed: () {
                      setState(() => _selectedRestaurant = null);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Rating
                  Icon(Icons.star, size: 18, color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),

                  // Tiempo
                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${restaurant.deliveryTime} min',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),

                  // Distancia
                  if (distanceText != null) ...[
                    const Icon(Icons.navigation, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      distanceText,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RestaurantDetailScreen(restaurant: restaurant),
                          ),
                        );
                      },
                      icon: const Icon(Icons.restaurant_menu, size: 18),
                      label: const Text('Ver Menú'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _openDirections(restaurant),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.directions, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDirections(Restaurant restaurant) async {
    // Abrir en Google Maps
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${restaurant.latitude},${restaurant.longitude}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

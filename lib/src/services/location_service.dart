import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;

class LocationService {
  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  // Verificar permisos de localización
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Obtener ubicación actual
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        debugPrint('Location permission denied');
        return null;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // Calcular distancia entre dos puntos (en kilómetros)
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Obtener distancia desde ubicación actual a un punto
  double? getDistanceFromCurrent({
    required double latitude,
    required double longitude,
  }) {
    if (_currentPosition == null) return null;

    return calculateDistance(
      lat1: _currentPosition!.latitude,
      lon1: _currentPosition!.longitude,
      lat2: latitude,
      lon2: longitude,
    );
  }

  // Formatear distancia para mostrar
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }
}

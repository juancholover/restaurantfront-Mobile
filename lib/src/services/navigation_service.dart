import 'package:flutter/material.dart';
import 'package:flutterlogin/src/providers/main_screen_provider.dart';
import 'package:provider/provider.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void navigateToCart() {
    // Usamos el contexto del navigatorKey para acceder al MainScreenProvider
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        // Intentar hacer pop de todas las rutas hasta la primera
        Navigator.of(context).popUntil((route) => route.isFirst);

        // Esperar un frame para asegurar que el pop se completó
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentContext != null) {
            // Cambiamos a la pestaña del carrito (índice 2)
            Provider.of<MainScreenProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).setPageIndex(2);
          }
        });
      } catch (e) {
        debugPrint('Error navegando al carrito: $e');
        // Plan B: Solo cambiar el índice si ya estamos en MainScreen
        try {
          Provider.of<MainScreenProvider>(
            context,
            listen: false,
          ).setPageIndex(2);
        } catch (e2) {
          debugPrint('Error en plan B: $e2');
        }
      }
    }
  }
}

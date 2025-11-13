import 'package:flutter/material.dart';
import 'restaurants_screen.dart';

//  PANTALLA DEPRECADA
// Esta pantalla ahora redirige a RestaurantsScreen
// que incluye todas las funcionalidades de búsqueda y filtrado
class SearchAndFilterScreen extends StatelessWidget {
  const SearchAndFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirigir inmediatamente a la pantalla principal de restaurantes
    // que tiene búsqueda, filtros, favoritos y compartir funcionando
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RestaurantsScreen(),
        ),
      );
    });

    // Mostrar un indicador de carga mientras se redirige
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

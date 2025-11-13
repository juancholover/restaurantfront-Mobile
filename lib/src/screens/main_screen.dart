import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterlogin/src/providers/main_screen_provider.dart';
import 'package:flutterlogin/src/screens/restaurants/restaurants_screen.dart';
import 'package:flutterlogin/src/screens/cart/cart_screen.dart';
import 'package:flutterlogin/src/screens/profile_screen.dart';
import 'package:flutterlogin/src/screens/favorites/favorites_screen.dart';
import 'package:flutterlogin/src/theme/app_theme.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainScreenProvider(),
      child: Consumer<MainScreenProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            body: IndexedStack(
              index: provider.pageIndex,
              children: const [
                RestaurantsScreen(),
                FavoritesScreen(),
                CartScreen(),
                ProfileScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: provider.pageIndex,
              onTap: (index) => provider.setPageIndex(index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.primaryOrange,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant),
                  label: 'Restaurantes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Favoritos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Carrito',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

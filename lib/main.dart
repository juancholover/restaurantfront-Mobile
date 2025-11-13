import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/services/auth_service.dart';
import 'src/services/payment_service.dart';
import 'src/theme/app_theme.dart';
import 'src/theme/theme_provider.dart';
import 'src/providers/restaurant_provider.dart';
import 'src/providers/product_provider.dart';
import 'src/providers/cart_provider.dart';
import 'src/providers/favorites_provider.dart';
import 'src/screens/welcome_screen.dart';
import 'src/screens/restaurants/restaurants_screen.dart';
import 'src/screens/profile_screen.dart';
import 'src/screens/cart/cart_screen.dart';
import 'src/screens/coupons/coupon_history_screen.dart';
import 'src/screens/admin/admin_coupon_screen.dart';
import 'src/screens/admin/admin_dashboard_screen.dart';
import 'src/screens/orders/order_history_screen.dart';
import 'package:flutterlogin/src/providers/main_screen_provider.dart';
import 'package:flutterlogin/src/screens/main_screen.dart';
import 'package:flutterlogin/src/services/navigation_service.dart';
import 'src/screens/checkout/checkout_screen.dart';
import 'src/screens/favorites/favorites_screen.dart';
import 'src/screens/restaurants/search_and_filter_screen.dart';
import 'src/screens/restaurants/restaurant_map_screen.dart';
import 'src/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar NotificationService para push notifications
  await NotificationService().initialize();

  // ⚠️ NO inicializar Stripe aquí - se hará lazy cuando se necesite

  final authService = AuthService();
  await authService.init();

  // Inicializar CartProvider y cargar carrito guardado
  final cartProvider = CartProvider();
  await cartProvider.loadCart();

  // Inicializar FavoritesProvider y cargar favoritos
  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFavorites();

  runApp(
    MyApp(
      authService: authService,
      cartProvider: cartProvider,
      favoritesProvider: favoritesProvider,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final CartProvider cartProvider;
  final FavoritesProvider favoritesProvider;

  const MyApp({
    required this.authService,
    required this.cartProvider,
    required this.favoritesProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<RestaurantProvider>(
          create: (_) => RestaurantProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
        ChangeNotifierProvider<FavoritesProvider>.value(
          value: favoritesProvider,
        ),
        ChangeNotifierProvider<MainScreenProvider>(
          create: (_) => MainScreenProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            title: 'Reserva & Delivery',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const WelcomeScreen(),
            routes: {
              '/main': (context) => const MainScreen(),
              '/restaurants': (context) => const RestaurantsScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/cart': (context) => const CartScreen(),
              '/coupon-history': (context) => const CouponHistoryScreen(),
              '/admin-coupons': (context) => const AdminCouponScreen(),
              '/admin-dashboard': (context) => const AdminDashboardScreen(),
              '/order-history': (context) => const OrderHistoryScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/favorites': (context) => const FavoritesScreen(),
              '/search': (context) => const SearchAndFilterScreen(),
              '/map': (context) => const RestaurantMapScreen(),
            },
          );
        },
      ),
    );
  }
}

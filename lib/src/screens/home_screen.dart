import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/shared_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: const [
              TextSpan(text: 'Joy'),
              TextSpan(
                text: 'Food',
                style: TextStyle(color: AppTheme.primaryOrange),
              ),
            ],
          ),
        ),
        actions: [
          // � Carrito
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: AppTheme.primaryOrange,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(cart.itemCount),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        tween: Tween(begin: 0.8, end: 1.0),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                cart.itemCount > 99
                                    ? '99+'
                                    : '${cart.itemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),

          // �👤 Perfil
          IconButton(
            icon: const Icon(Icons.person, color: AppTheme.primaryOrange),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),

          // 🌗 Toggle de tema
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.primaryOrange,
            ),
            onPressed: themeProvider.toggleTheme,
          ),

          // 🚪 Logout
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.primaryOrange),
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              goToWelcome(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de bienvenida
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, AppTheme.accentYellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenido,',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.userName ?? 'Usuario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🎉 Listo para ordenar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Próximamente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.restaurant,
                    title: 'Restaurantes',
                    subtitle: 'Explorar menús',
                    color: AppTheme.primaryOrange,
                    onTap: () {
                      Navigator.pushNamed(context, '/restaurants');
                    },
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.map,
                    title: 'Mapa',
                    subtitle: 'Ubicaciones',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pushNamed(context, '/map');
                    },
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.delivery_dining,
                    title: 'Delivery',
                    subtitle: 'Ordena ahora',
                    color: AppTheme.accentYellow,
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.event_available,
                    title: 'Reservas',
                    subtitle: 'Reserva mesa',
                    color: Colors.blue,
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.favorite,
                    title: 'Favoritos',
                    subtitle: 'Mis lugares',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pushNamed(context, '/favorites');
                    },
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.history,
                    title: 'Pedidos',
                    subtitle: 'Mi historial',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pushNamed(context, '/order-history');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

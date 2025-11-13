import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../utils/fade_slide_wrapper.dart';
import '../utils/shared_navigation.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo principal
          const AppImage(
            assetPath: 'assets/images/fondo.png',
            fit: BoxFit.cover,
          ),
          // Capa oscura para mejorar contraste
          Container(color: Colors.black.withOpacity(0.55)),

          // Contenido animado
          FadeSlideWrapper(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo simple en el centro superior
                  Hero(
                    tag: 'chefLogo',
                    child: ClipOval(
                      child: AppImage(
                        assetPath: 'assets/images/chef.png',
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Título y texto descriptivo
                  const Text(
                    "Bienvenido a",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Text(
                    "JoyFood",
                    style: TextStyle(
                      color: AppTheme.accentYellow,
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Reserva y ordena comida de tus restaurantes favoritos de forma rápida y sencilla.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  // Botones
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => goToLogin(context),
                    child: const Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón Registrarse
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                    onPressed: () => goToRegister(context),
                    child: const Text(
                      "Registrarse",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

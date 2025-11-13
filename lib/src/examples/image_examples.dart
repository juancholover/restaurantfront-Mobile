import 'package:flutter/material.dart';
import '../widgets/app_image.dart';

/// EJEMPLOS DE CÓMO USAR IMÁGENES EN FLUTTER
/// Este archivo es solo de referencia - NO se usa en la app

class ImageExamples extends StatelessWidget {
  const ImageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplos de Imágenes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============================================
          // 1. IMAGEN LOCAL (ASSET)
          // ============================================
          _buildExample(
            'Imagen Local (Asset)',
            'Debes tener la imagen en assets/images/',
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),

          // ============================================
          // 2. IMAGEN DESDE URL (INTERNET)
          // ============================================
          _buildExample(
            'Imagen desde URL',
            'Carga desde internet con loading y error',
            Image.network(
              'https://picsum.photos/200',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
            ),
          ),

          // ============================================
          // 3. USAR AppImage WIDGET (RECOMENDADO)
          // ============================================
          _buildExample(
            'AppImage Widget - Local',
            'Intenta cargar asset, si falla muestra fallback',
            const AppImage(
              assetPath: 'assets/images/chef_illustration.png',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),

          _buildExample(
            'AppImage Widget - URL',
            'Intenta cargar desde URL con loading automático',
            const AppImage(
              url: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),

          // ============================================
          // 4. IMAGEN CIRCULAR (AVATAR)
          // ============================================
          _buildExample(
            'Imagen Circular',
            'Para avatares o logos redondos',
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, size: 80);
                },
              ),
            ),
          ),

          // ============================================
          // 5. IMAGEN CON BORDES REDONDEADOS
          // ============================================
          _buildExample(
            'Imagen con Bordes Redondeados',
            'Para cards o thumbnails',
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
                width: 200,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  );
                },
              ),
            ),
          ),

          // ============================================
          // 6. IMAGEN DE FONDO (BACKGROUND)
          // ============================================
          _buildExample(
            'Imagen de Fondo',
            'Para usar como background de Container',
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                // Overlay oscuro para que el texto sea legible
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Restaurante Elegante',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // ============================================
          // 7. LISTA DE IMÁGENES (LISTVIEW)
          // ============================================
          _buildExample(
            'Lista de Imágenes',
            'Ejemplo de ListView con imágenes',
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://picsum.photos/150/100?random=$index',
                        width: 150,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ============================================
          // 8. GRID DE IMÁGENES
          // ============================================
          _buildExample(
            'Grid de Imágenes',
            'Ejemplo de GridView con imágenes',
            SizedBox(
              height: 250,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://picsum.photos/100?random=${index + 10}',
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),

          // ============================================
          // 9. ÍCONOS DE REDES SOCIALES
          // ============================================
          _buildExample(
            'Íconos de Redes Sociales',
            'Puedes usar assets locales o Material Icons',
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Opción 1: Usar asset local
                Image.asset(
                  'assets/icons/facebook.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.facebook, size: 32);
                  },
                ),
                const SizedBox(width: 16),
                // Opción 2: Usar Material Icon
                const Icon(Icons.facebook, size: 32, color: Color(0xFF1877F2)),
                const SizedBox(width: 16),
                const Icon(
                  Icons.g_mobiledata,
                  size: 32,
                  color: Color(0xFFDB4437),
                ),
              ],
            ),
          ),

          // ============================================
          // 10. PLACEHOLDER MIENTRAS CARGA
          // ============================================
          _buildExample(
            'Imagen con Placeholder Shimmer',
            'Efecto de carga más profesional',
            Image.network(
              'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445',
              width: 200,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExample(String title, String description, Widget example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: example),
          ),
        ],
      ),
    );
  }
}

/*
═══════════════════════════════════════════════════════════════
PASOS PARA USAR IMÁGENES EN TU APP:
═══════════════════════════════════════════════════════════════

1. AÑADIR IMÁGENES LOCALES:
   - Coloca tus imágenes en: assets/images/
   - Ejemplo: assets/images/logo.png
   - Ejecuta: flutter pub get

2. USAR EN EL CÓDIGO:
   Image.asset('assets/images/logo.png')

3. DESDE URL:
   Image.network('https://ejemplo.com/imagen.jpg')

4. CON EL WIDGET HELPER (RECOMENDADO):
   AppImage(
     assetPath: 'assets/images/logo.png',
     width: 100,
     height: 100,
   )

═══════════════════════════════════════════════════════════════
RECURSOS GRATUITOS:
═══════════════════════════════════════════════════════════════

Ilustraciones:
- https://undraw.co/illustrations
- https://storyset.com/

Fotos de comida:
- https://unsplash.com/s/photos/food
- https://pexels.com/search/restaurant/

Íconos:
- https://flaticon.com/
- https://icons8.com/

═══════════════════════════════════════════════════════════════
*/

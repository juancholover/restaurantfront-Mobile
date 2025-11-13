Proyecto: Flutter - JoyFood (Login & Reserva/Delivery)

## Descripción
Aplicación móvil profesional de login para app de reservas y delivery en restaurantes, con diseño moderno inspirado en JoyFood. Incluye autenticación mock con almacenamiento seguro, pantalla de bienvenida, login con validación, y navegación a home.

## Características
- ✅ **Pantalla de bienvenida** con ilustración y botones de Log in / Sign up
- ✅ **Login profesional** con:
  - Campos de email y password con validación
  - Toggle para mostrar/ocultar contraseña
  - Checkbox "Remember me"
  - Link "Forgot password" (auto-rellena credenciales demo)
  - Botones de login social (Facebook, Google) - UI preparada
  - Link para registro "Sign up"
- ✅ **Tema personalizado** JoyFood (colores naranjas/amarillos, tipografía Poppins)
- ✅ **AuthService mock** con `flutter_secure_storage` para persistir tokens
- ✅ **Home screen** con card de bienvenida y secciones próximas (Restaurantes, Delivery, Reservas, Favoritos)
- ✅ **Logout** funcional

## Archivos principales
- `lib/main.dart` — Punto de entrada con Provider y navegación condicional
- `lib/src/services/auth_service.dart` — Servicio de autenticación (mock)
- `lib/src/screens/welcome_screen.dart` — Pantalla de bienvenida/onboarding
- `lib/src/screens/login_screen.dart` — Pantalla de login con diseño JoyFood
- `lib/src/screens/home_screen.dart` — Pantalla principal con módulos futuros
- `lib/src/theme/app_theme.dart` — Tema personalizado (colores y estilos)

## Dependencias
- `provider` — Gestión de estado
- `http` — Para llamadas HTTP (futuro)
- `flutter_secure_storage` — Almacenamiento seguro de tokens
- `google_fonts` — Tipografía Poppins
- `font_awesome_flutter` — Íconos de redes sociales (Facebook, Google, etc.)

## Cómo ejecutar

### Prerequisitos
- Flutter SDK 3.x instalado
- Emulador Android/iOS o dispositivo físico conectado

### Pasos
1. Navega al proyecto:
   ```cmd
   cd C:\Cursos\Aplicacionesmobiles\flutterlogin
   ```

2. Instala dependencias:
   ```cmd
   flutter pub get
   ```

3. Ejecuta la app:
   ```cmd
   flutter run
   ```

### Credenciales demo
En la pantalla de login, haz clic en **"Forgot password?"** para auto-rellenar:
- **Email**: demo@rest.com
- **Password**: 123456

## 📸 Cómo añadir imágenes

### Estructura de carpetas
```
assets/
├── images/          # Ilustraciones, fotos, backgrounds
│   ├── logo.png
│   ├── chef_illustration.png
│   └── welcome_bg.png
└── icons/           # Íconos pequeños
    ├── facebook.png
    └── google.png
```

### 1. Añadir imágenes locales
1. Coloca tus imágenes en `assets/images/` o `assets/icons/`
2. El `pubspec.yaml` ya está configurado para cargarlas
3. Ejecuta `flutter pub get`
4. Usa en el código:
   ```dart
   Image.asset('assets/images/logo.png', width: 100, height: 100)
   ```

### 2. Usar el widget helper (recomendado)
```dart
import '../widgets/app_image.dart';

AppImage(
  assetPath: 'assets/images/logo.png',
  width: 100,
  height: 100,
  // Si la imagen no existe, muestra este fallback
  errorWidget: Icon(Icons.restaurant),
)
```

### 3. Cargar desde URL
```dart
AppImage(
  url: 'https://ejemplo.com/imagen.jpg',
  width: 100,
  height: 100,
)
```

### 📦 Dónde conseguir imágenes gratuitas

**Ilustraciones:**
- [Undraw](https://undraw.co/illustrations) - Ilustraciones SVG personalizables
- [Storyset](https://storyset.com/) - Ilustraciones animadas
- [Freepik](https://www.freepik.com/) - Requiere atribución

**Fotos de comida/restaurantes:**
- [Unsplash](https://unsplash.com/s/photos/food)
- [Pexels](https://www.pexels.com/search/restaurant/)
- [Pixabay](https://pixabay.com/images/search/food/)

**Íconos:**
- [Flaticon](https://www.flaticon.com/)
- [Icons8](https://icons8.com/icons)

**Términos de búsqueda recomendados:**
- "chef illustration"
- "food delivery illustration"
- "restaurant vector"
- "cooking illustration"

### 📖 Ejemplos de uso
Revisa el archivo `lib/src/examples/image_examples.dart` para ver 10 ejemplos diferentes de cómo usar imágenes.

Más detalles en: `assets/README_ASSETS.md`

## Estructura del proyecto
```
lib/
├── main.dart
└── src/
    ├── screens/
    │   ├── welcome_screen.dart
    │   ├── login_screen.dart
    │   └── home_screen.dart
    ├── services/
    │   └── auth_service.dart
    ├── widgets/
    │   └── primary_button.dart
    └── theme/
        └── app_theme.dart
```

## Siguientes pasos recomendados

### Backend & API
- [ ] Conectar `AuthService.login()` a API REST real
- [ ] Implementar refresh tokens y manejo de expiración
- [ ] Añadir endpoints de registro y recuperación de contraseña
- [ ] Integrar social login (Firebase Auth, Google Sign-In, Facebook Login)

### UI/UX
- [ ] Añadir ilustraciones personalizadas (reemplazar íconos)
- [ ] Implementar animaciones de transición entre pantallas
- [ ] Crear pantalla de registro completa
- [ ] Diseñar pantallas de: listado de restaurantes, detalle, carrito, checkout, historial de pedidos

### Funcionalidades
- [ ] Módulo de búsqueda de restaurantes con filtros
- [ ] Sistema de reservas con calendario
- [ ] Carrito de compras y checkout
- [ ] Integración con pasarelas de pago
- [ ] Notificaciones push
- [ ] Sistema de ratings y reseñas

### Testing & QA
- [ ] Tests unitarios para `AuthService`
- [ ] Tests de widget para pantallas principales
- [ ] Tests de integración end-to-end
- [ ] Pruebas en dispositivos iOS y Android

### Deployment
- [ ] Configurar firma de app (Android keystore, iOS certificates)
- [ ] Preparar assets para stores (íconos, screenshots, descripción)
- [ ] Build de release y publicación en Google Play Store / App Store
- [ ] Configurar CI/CD con GitHub Actions

## Notas técnicas
- El login actual es **mock** y acepta cualquier email con contraseña >= 4 caracteres
- El token se guarda en `flutter_secure_storage` pero no se valida (implementar JWT en backend real)
- Los botones de social login son solo UI, falta integrar SDKs

## Licencia
Proyecto educativo - Libre uso
# flutterlogin

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 📁 Guía de Assets (Imágenes)

## Dónde poner las imágenes

### Estructura de carpetas
```
assets/
├── images/          # Ilustraciones, fotos, backgrounds
│   ├── logo.png
│   ├── chef_illustration.png
│   ├── welcome_bg.png
│   └── restaurant_placeholder.jpg
└── icons/           # Íconos pequeños, badges
    ├── facebook.png
    ├── google.png
    └── delivery.png
```

## Formatos recomendados
- **PNG**: Para logos, ilustraciones con transparencia
- **JPG**: Para fotos, backgrounds
- **SVG**: Se necesita paquete `flutter_svg` (no incluido por defecto)

## Tamaños recomendados
- **Logo**: 512x512px o 1024x1024px
- **Ilustraciones**: 800x800px mínimo
- **Íconos sociales**: 48x48px o 96x96px
- **Backgrounds**: 1080x1920px (full screen)

## Cómo obtener imágenes gratuitas

### Ilustraciones
- **Undraw**: https://undraw.co/illustrations (ilustraciones SVG personalizables)
- **Storyset**: https://storyset.com/ (ilustraciones animadas)
- **Freepik**: https://www.freepik.com/ (requiere atribución)

### Íconos
- **Flaticon**: https://www.flaticon.com/
- **Icons8**: https://icons8.com/icons
- **Material Icons**: Ya incluido en Flutter (Icons.xxx)

### Fotos de comida/restaurantes
- **Unsplash**: https://unsplash.com/s/photos/food
- **Pexels**: https://www.pexels.com/search/restaurant/
- **Pixabay**: https://pixabay.com/images/search/food/

## Ejemplos de búsqueda
Para tu app "JoyFood", busca:
- "chef illustration"
- "food delivery illustration"
- "restaurant vector"
- "cooking illustration"
- "food app icon"

## Después de descargar
1. Coloca las imágenes en `assets/images/` o `assets/icons/`
2. Renombra con nombres descriptivos sin espacios: `chef_illustration.png`
3. Ejecuta `flutter pub get` para que Flutter detecte los nuevos assets
4. Usa en el código como se muestra en los ejemplos del proyecto

## Optimización
- Comprime imágenes PNG: https://tinypng.com/
- Comprime imágenes JPG: https://compressjpeg.com/
- Tamaño máximo recomendado por imagen: 500KB

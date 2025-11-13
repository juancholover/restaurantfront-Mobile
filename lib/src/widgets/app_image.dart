import 'package:flutter/material.dart';

/// Helper widget para mostrar imágenes con fallback
/// Soporta assets locales y URLs
class AppImage extends StatelessWidget {
  final String? assetPath;
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    this.assetPath,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : assert(
         assetPath != null || url != null,
         'Debe proporcionar assetPath o url',
       );

  @override
  Widget build(BuildContext context) {
    // Prioridad: asset local > URL
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorWidget();
        },
      );
    }

    if (url != null) {
      return Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorWidget();
        },
      );
    }

    return _buildErrorWidget();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(Icons.broken_image, color: Colors.grey[400], size: 48),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/error_response.dart';

/// Widget para mostrar errores de forma elegante
class ErrorDialog extends StatelessWidget {
  final ErrorResponse error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    required this.error,
    this.onRetry,
    this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(error.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(error.error, style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error.userFriendlyMessage,
              style: const TextStyle(fontSize: 14),
            ),
            if (error.details != null && error.details!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Detalles:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              ...error.details!.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${entry.key}: ${entry.value}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Código: ${error.status}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      actions: [
        if (onRetry != null)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  /// Muestra el diálogo de error
  static Future<void> show(
    BuildContext context,
    ErrorResponse error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      builder: (context) =>
          ErrorDialog(error: error, onRetry: onRetry, onDismiss: onDismiss),
    );
  }
}

/// Widget para mostrar errores en pantalla completa
class ErrorScreen extends StatelessWidget {
  final ErrorResponse error;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const ErrorScreen({
    required this.error,
    this.onRetry,
    this.retryButtonText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              error.error,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              error.userFriendlyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? 'Reintentar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// SnackBar personalizado para errores
class ErrorSnackBar {
  static void show(BuildContext context, ErrorResponse error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(error.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    error.error,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    error.message,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getBackgroundColor(error.status),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ver más',
          textColor: Colors.white,
          onPressed: () {
            ErrorDialog.show(context, error);
          },
        ),
      ),
    );
  }

  static Color _getBackgroundColor(int status) {
    switch (status) {
      case 400:
        return Colors.orange;
      case 401:
      case 403:
        return Colors.red;
      case 404:
        return Colors.blue;
      case 409:
        return Colors.deepOrange;
      case 500:
        return Colors.red[900]!;
      default:
        return Colors.grey[800]!;
    }
  }
}

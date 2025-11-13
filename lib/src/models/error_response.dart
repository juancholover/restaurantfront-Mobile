class ErrorResponse {
  final String timestamp;
  final int status;
  final String error;
  final String message;
  final String path;
  final String? exceptionType;
  final Map<String, dynamic>? details;
  final String? stackTrace;

  ErrorResponse({
    required this.timestamp,
    required this.status,
    required this.error,
    required this.message,
    required this.path,
    this.exceptionType,
    this.details,
    this.stackTrace,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      timestamp: json['timestamp'] ?? '',
      status: json['status'] ?? 0,
      error: json['error'] ?? 'Error',
      message: json['message'] ?? 'Ha ocurrido un error',
      path: json['path'] ?? '',
      exceptionType: json['exceptionType'],
      details: json['details'] as Map<String, dynamic>?,
      stackTrace: json['stackTrace'],
    );
  }

  /// Obtiene el mensaje amigable para el usuario
  String get userFriendlyMessage {
    // Si hay detalles, intentar extraer información útil
    if (details != null && details!.isNotEmpty) {
      // Para errores de validación
      if (exceptionType == 'MethodArgumentNotValidException') {
        final errors = <String>[];
        details!.forEach((field, error) {
          errors.add('• $field: $error');
        });
        return 'Errores de validación:\n${errors.join('\n')}';
      }
    }

    return message;
  }

  /// Obtiene el emoji según el tipo de error
  String get emoji {
    switch (status) {
      case 400:
        return '⚠️';
      case 401:
        return '🔒';
      case 403:
        return '🚫';
      case 404:
        return '🔍';
      case 409:
        return '⚠️';
      case 500:
        return '❌';
      default:
        return '❌';
    }
  }

  /// Obtiene el color según el tipo de error
  String get colorHex {
    switch (status) {
      case 400:
        return '#FF9800'; // Orange
      case 401:
        return '#F44336'; // Red
      case 403:
        return '#E91E63'; // Pink
      case 404:
        return '#2196F3'; // Blue
      case 409:
        return '#FF5722'; // Deep Orange
      case 500:
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  bool get isClientError => status >= 400 && status < 500;
  bool get isServerError => status >= 500;
  bool get isNotFound => status == 404;
  bool get isUnauthorized => status == 401;
  bool get isForbidden => status == 403;
  bool get isBadRequest => status == 400;
  bool get isConflict => status == 409;

  @override
  String toString() {
    return 'ErrorResponse($status $error: $message)';
  }
}

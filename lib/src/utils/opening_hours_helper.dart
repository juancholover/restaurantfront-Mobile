import 'package:flutter/material.dart';

/// Helper para trabajar con horarios de apertura de restaurantes
class OpeningHoursHelper {
  /// Verifica si un restaurante está abierto actualmente
  ///
  /// Formatos soportados:
  /// - "9:00 AM - 10:00 PM"
  /// - "09:00 - 22:00"
  /// - "Lun-Vie: 9:00 AM - 10:00 PM, Sáb-Dom: 10:00 AM - 11:00 PM"
  /// - "24 horas" o "Abierto 24 horas"
  static bool isOpenNow(String openingHours) {
    final now = DateTime.now();

    // Caso especial: 24 horas
    if (openingHours.toLowerCase().contains('24') ||
        openingHours.toLowerCase().contains('siempre')) {
      return true;
    }

    // Obtener día de la semana
    final weekday = now.weekday; // 1 = Lunes, 7 = Domingo

    // Verificar si tiene horarios por día
    if (openingHours.contains('Lun') ||
        openingHours.contains('Sáb') ||
        openingHours.contains('Dom')) {
      return _checkDaySpecificHours(openingHours, now, weekday);
    }

    // Horario simple (mismo todos los días)
    return _checkSimpleHours(openingHours, now);
  }

  /// Verifica horarios específicos por día
  static bool _checkDaySpecificHours(
    String openingHours,
    DateTime now,
    int weekday,
  ) {
    // Ejemplo: "Lun-Vie: 9:00 AM - 10:00 PM, Sáb-Dom: 10:00 AM - 11:00 PM"
    final parts = openingHours.split(',');

    for (var part in parts) {
      if (part.contains(':')) {
        final segments = part.split(':');
        if (segments.length < 2) continue;

        final daysPart = segments[0].trim();
        final timePart = segments.sublist(1).join(':').trim();

        // Verificar si el día actual está en el rango
        if (_isDayInRange(daysPart, weekday)) {
          return _checkSimpleHours(timePart, now);
        }
      }
    }

    return false;
  }

  /// Verifica si el día actual está en el rango especificado
  static bool _isDayInRange(String dayRange, int weekday) {
    // Lun-Vie
    if (dayRange.contains('Lun') && dayRange.contains('Vie')) {
      return weekday >= 1 && weekday <= 5;
    }
    // Sáb-Dom
    if (dayRange.contains('Sáb') && dayRange.contains('Dom')) {
      return weekday == 6 || weekday == 7;
    }
    // Lun, Mar, etc.
    final dayMap = {
      'Lun': 1,
      'Mar': 2,
      'Mié': 3,
      'Jue': 4,
      'Vie': 5,
      'Sáb': 6,
      'Dom': 7,
    };

    for (var entry in dayMap.entries) {
      if (dayRange.contains(entry.key) && weekday == entry.value) {
        return true;
      }
    }

    return false;
  }

  /// Verifica horarios simples (mismo horario todos los días)
  static bool _checkSimpleHours(String hours, DateTime now) {
    try {
      // Buscar patrón "HH:MM AM/PM - HH:MM AM/PM" o "HH:MM - HH:MM"
      final pattern = RegExp(
        r'(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)?\s*-\s*(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)?',
      );

      final match = pattern.firstMatch(hours);
      if (match == null) return true; // Si no puede parsear, asume abierto

      // Hora de apertura
      int openHour = int.parse(match.group(1)!);
      final openMinute = int.parse(match.group(2)!);
      final openPeriod = match.group(3)?.toUpperCase();

      if (openPeriod == 'PM' && openHour != 12) {
        openHour += 12;
      } else if (openPeriod == 'AM' && openHour == 12) {
        openHour = 0;
      }

      // Hora de cierre
      int closeHour = int.parse(match.group(4)!);
      final closeMinute = int.parse(match.group(5)!);
      final closePeriod = match.group(6)?.toUpperCase();

      if (closePeriod == 'PM' && closeHour != 12) {
        closeHour += 12;
      } else if (closePeriod == 'AM' && closeHour == 12) {
        closeHour = 0;
      }

      // Crear fechas para comparar
      final openTime = DateTime(
        now.year,
        now.month,
        now.day,
        openHour,
        openMinute,
      );

      var closeTime = DateTime(
        now.year,
        now.month,
        now.day,
        closeHour,
        closeMinute,
      );

      // Si cierra después de medianoche
      if (closeTime.isBefore(openTime)) {
        closeTime = closeTime.add(const Duration(days: 1));
      }

      return now.isAfter(openTime) && now.isBefore(closeTime);
    } catch (e) {
      // Si hay error al parsear, asume abierto
      return true;
    }
  }

  /// Obtiene la siguiente hora de apertura
  static String getNextOpeningTime(String openingHours) {
    if (isOpenNow(openingHours)) {
      return 'Abierto ahora';
    }

    // Por ahora retorna horario simple
    // TODO: Calcular próxima apertura basado en día y hora
    return 'Abre: $openingHours';
  }

  /// Obtiene el estado formateado del restaurante
  static Map<String, dynamic> getOpenStatus(String openingHours) {
    final isOpen = isOpenNow(openingHours);

    return {
      'isOpen': isOpen,
      'text': isOpen ? 'Abierto ahora' : 'Cerrado',
      'color': isOpen ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
    };
  }

  /// Formatea los horarios para mostrar de manera legible
  static String formatHours(String openingHours) {
    // Si ya está bien formateado, retornarlo
    if (openingHours.contains('AM') || openingHours.contains('PM')) {
      return openingHours;
    }

    // Intentar convertir formato 24h a 12h
    final pattern = RegExp(r'(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})');
    final match = pattern.firstMatch(openingHours);

    if (match != null) {
      final openHour = int.parse(match.group(1)!);
      final openMin = match.group(2)!;
      final closeHour = int.parse(match.group(3)!);
      final closeMin = match.group(4)!;

      final openFormatted = _formatTime(openHour, openMin);
      final closeFormatted = _formatTime(closeHour, closeMin);

      return '$openFormatted - $closeFormatted';
    }

    return openingHours;
  }

  static String _formatTime(int hour, String minute) {
    if (hour == 0) {
      return '12:$minute AM';
    } else if (hour < 12) {
      return '$hour:$minute AM';
    } else if (hour == 12) {
      return '12:$minute PM';
    } else {
      return '${hour - 12}:$minute PM';
    }
  }
}

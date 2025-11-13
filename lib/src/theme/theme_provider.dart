import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Provider que controla el modo oscuro / claro de la app.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme =>
      _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

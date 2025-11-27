import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import 'page_transitions.dart';

/// Navega al Login desde cualquier pantalla
void goToLogin(BuildContext context, {bool replace = true}) {
  final route = fadeSlideTransition(const LoginScreen());
  if (replace) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).push(route);
  }
}

/// Navega al Register desde cualquier pantalla
void goToRegister(BuildContext context, {bool replace = true}) {
  final route = fadeSlideTransition(const RegisterScreen());
  if (replace) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).push(route);
  }
}

/// Navega al Home (menú principal) desde cualquier pantalla
void goToHome(BuildContext context, {bool replace = true}) {
  if (replace) {
    Navigator.of(context).pushReplacementNamed('/main');
  } else {
    Navigator.of(context).pushNamed('/main');
  }
}

/// Navega al Welcome (pantalla de inicio)
void goToWelcome(BuildContext context, {bool clearStack = true}) {
  final route = fadeSlideTransition(const WelcomeScreen());
  if (clearStack) {
    Navigator.of(context).pushAndRemoveUntil(route, (r) => false);
  } else {
    Navigator.of(context).push(route);
  }
}

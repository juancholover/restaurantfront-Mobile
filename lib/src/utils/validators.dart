class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
    if (!value.contains('@')) return 'Correo inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu contraseña';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    if (!value.contains(RegExp(r'[A-Z]')) &&
        !value.contains(RegExp(r'[a-z]'))) {
      return 'Debe contener al menos una letra';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }

    return null;
  }

  static String? passwordSimple(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu contraseña';
    }

    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }

    return null;
  }
}

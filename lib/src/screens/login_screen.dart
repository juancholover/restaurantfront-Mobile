import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/app_image.dart';
import '../utils/fade_slide_wrapper.dart';
import '../utils/shared_navigation.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final success = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    setState(() => _loading = false);

    if (success) {
      if (!mounted) return;
      goToHome(context);
    } else {
      setState(() => _error = 'Credenciales inválidas. Intenta de nuevo.');
    }
  }

  void _loginWithFacebook() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Iniciar sesión con Facebook (pendiente)')),
    );
  }

  void _loginWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Iniciar sesión con Google (pendiente)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeSlideWrapper(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // 🔆 Toggle de tema arriba a la derecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: AppTheme.primaryOrange,
                      ),
                      onPressed: themeProvider.toggleTheme,
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                _buildHeader(),
                const SizedBox(height: 40),

                // Texto principal
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    children: [
                      const TextSpan(text: 'Bienvenido a\n'),
                      TextSpan(
                        text: 'Joy',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const TextSpan(
                        text: 'Food',
                        style: TextStyle(color: AppTheme.primaryOrange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Formulario
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Correo electrónico',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'ejemplo@gmail.com',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Contraseña',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        validator: Validators.passwordSimple,
                        decoration: InputDecoration(
                          hintText: '••••••••••••',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Recordarme
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val ?? false;
                              });
                            },
                            activeColor: AppTheme.primaryOrange,
                          ),
                          const Text('Recordarme'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],

                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _loading ? 'Ingresando...' : 'Iniciar sesión',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('O inicia con'),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Botones sociales
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _socialButton(
                            label: "Facebook",
                            color: const Color(0xFF1877F2),
                            icon: Icons.facebook,
                            onTap: _loginWithFacebook,
                          ),
                          const SizedBox(width: 12),
                          _socialButton(
                            label: "Google",
                            color: const Color(0xFFDB4437),
                            icon: Icons.g_mobiledata,
                            onTap: _loginWithGoogle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Registro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "¿No tienes cuenta? ",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () => goToRegister(context),
                            child: const Text(
                              'Regístrate',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Hero(
        tag: 'chefLogo',
        child: ClipOval(
          child: AppImage(
            assetPath: 'assets/images/chef.png',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _socialButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

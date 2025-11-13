import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/app_image.dart';
import '../utils/fade_slide_wrapper.dart';
import '../utils/shared_navigation.dart';
import '../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      setState(() => _error = 'Debes aceptar los términos y condiciones');
      return;
    }

    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    setState(() => _loading = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Bienvenido'),
          backgroundColor: Colors.green,
        ),
      );
      goToHome(context);
    } else {
      setState(() => _error = 'Error al registrarse. Intenta de nuevo.');
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.description, color: AppTheme.primaryOrange),
              const SizedBox(width: 8),
              const Text('Términos y Condiciones'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Última actualización: Noviembre 2025',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),

                _buildTermSection(
                  '1. Aceptación de los términos',
                  'Al registrarte en JoyFood, aceptas estar sujeto a estos términos y condiciones. Si no estás de acuerdo, no uses nuestra plataforma.',
                ),

                _buildTermSection(
                  '2. Uso del servicio',
                  'JoyFood es una plataforma para ordenar comida de restaurantes locales. Debes tener al menos 18 años para usar nuestros servicios.',
                ),

                _buildTermSection(
                  '3. Cuenta de usuario',
                  'Eres responsable de mantener la confidencialidad de tu cuenta y contraseña. No compartas tus credenciales con terceros.',
                ),

                _buildTermSection(
                  '4. Pedidos y pagos',
                  'Todos los pedidos están sujetos a disponibilidad. Los precios pueden variar sin previo aviso. Los pagos se procesan de forma segura.',
                ),

                _buildTermSection(
                  '5. Privacidad',
                  'Respetamos tu privacidad. Tus datos personales se utilizarán únicamente para procesar pedidos y mejorar nuestros servicios.',
                ),

                _buildTermSection(
                  '6. Cancelaciones',
                  'Puedes cancelar un pedido antes de que sea confirmado por el restaurante. Una vez confirmado, aplicarán las políticas del restaurante.',
                ),

                _buildTermSection(
                  '7. Limitación de responsabilidad',
                  'JoyFood actúa como intermediario entre clientes y restaurantes. No somos responsables de la calidad de la comida.',
                ),

                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Al aceptar, confirmas haber leído y entendido estos términos.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _acceptTerms = true;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
              ),
              child: const Text('Aceptar términos'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _loginWithFacebook() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrarse con Facebook (pendiente)')),
    );
  }

  void _loginWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrarse con Google (pendiente)')),
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

                // Botón de regreso y toggle de tema
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
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
                const SizedBox(height: 32),

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
                      const TextSpan(text: 'Crear Cuenta en\n'),
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
                        'Nombre completo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Ingresa tu nombre';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Juan Pérez',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                      const SizedBox(height: 20),

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
                        validator: Validators.password,
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
                      const SizedBox(height: 20),

                      Text(
                        'Confirmar contraseña',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirmPassword,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Confirma tu contraseña';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '••••••••••••',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Términos y condiciones
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (val) {
                              setState(() {
                                _acceptTerms = val ?? false;
                              });
                            },
                            activeColor: AppTheme.primaryOrange,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _showTermsDialog,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  children: [
                                    const TextSpan(text: 'Acepto los '),
                                    TextSpan(
                                      text: 'términos y condiciones',
                                      style: TextStyle(
                                        color: AppTheme.primaryOrange,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
                          _loading ? 'Registrando...' : 'Registrarse',
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
                            child: Text('O regístrate con'),
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

                      // Ya tienes cuenta
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "¿Ya tienes cuenta? ",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () => goToLogin(context),
                            child: const Text(
                              'Inicia sesión',
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

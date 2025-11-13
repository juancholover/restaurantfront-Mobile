import 'package:flutter/material.dart';
import '../../services/coupon_service.dart';

/// Pantalla para crear cupones (solo ADMIN)
class AdminCouponScreen extends StatefulWidget {
  const AdminCouponScreen({super.key});

  @override
  State<AdminCouponScreen> createState() => _AdminCouponScreenState();
}

class _AdminCouponScreenState extends State<AdminCouponScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minimumAmountController = TextEditingController();
  final _maximumDiscountController = TextEditingController();
  final _usageLimitController = TextEditingController();
  final _userUsageLimitController = TextEditingController();

  String _discountType = 'FIXED'; // FIXED o PERCENTAGE
  bool _isActive = true;
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 30));
  bool _isCreating = false;

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minimumAmountController.dispose();
    _maximumDiscountController.dispose();
    _usageLimitController.dispose();
    _userUsageLimitController.dispose();
    super.dispose();
  }

  Future<void> _createCoupon() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isCreating = true);

    try {
      final couponService = CouponService();

      final result = await couponService.createCoupon(
        code: _codeController.text.toUpperCase(),
        description: _descriptionController.text,
        discountType: _discountType,
        discountValue: double.parse(_discountValueController.text),
        minimumAmount: double.parse(_minimumAmountController.text),
        maximumDiscount: _maximumDiscountController.text.isNotEmpty
            ? double.parse(_maximumDiscountController.text)
            : null,
        isActive: _isActive,
        expiresAt: _expiresAt.toIso8601String(),
        usageLimit: int.parse(_usageLimitController.text),
        userUsageLimit: int.parse(_userUsageLimitController.text),
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Cupón "${result['code']}" creado exitosamente'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Limpiar formulario
        _formKey.currentState!.reset();
        _codeController.clear();
        _descriptionController.clear();
        _discountValueController.clear();
        _minimumAmountController.clear();
        _maximumDiscountController.clear();
        _usageLimitController.clear();
        _userUsageLimitController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Error al crear cupón')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _selectExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecciona fecha de expiración',
    );

    if (picked != null) {
      setState(() {
        _expiresAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          23,
          59,
          59,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cupón'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Encabezado
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Panel de Administrador',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Crea cupones de descuento para tus clientes',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Código del cupón
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Código del cupón *',
                hintText: 'Ej: DESCUENTO10',
                prefixIcon: Icon(Icons.local_offer),
                border: OutlineInputBorder(),
                helperText: 'Solo letras y números, sin espacios',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un código';
                }
                if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value.toUpperCase())) {
                  return 'Solo letras y números';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                hintText: 'Ej: 10% de descuento en tu pedido',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa una descripción';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Tipo de descuento
            const Text(
              'Tipo de descuento',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Fijo (S/)'),
                    value: 'FIXED',
                    groupValue: _discountType,
                    onChanged: (value) {
                      setState(() => _discountType = value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Porcentaje (%)'),
                    value: 'PERCENTAGE',
                    groupValue: _discountType,
                    onChanged: (value) {
                      setState(() => _discountType = value!);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Valor del descuento
            TextFormField(
              controller: _discountValueController,
              decoration: InputDecoration(
                labelText: 'Valor del descuento *',
                hintText: _discountType == 'FIXED' ? 'Ej: 10.00' : 'Ej: 10',
                prefixIcon: const Icon(Icons.discount),
                suffixText: _discountType == 'FIXED' ? 'S/' : '%',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el valor';
                }
                final num = double.tryParse(value);
                if (num == null || num <= 0) {
                  return 'Debe ser mayor a 0';
                }
                if (_discountType == 'PERCENTAGE' && num > 100) {
                  return 'No puede ser mayor a 100%';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Monto mínimo
            TextFormField(
              controller: _minimumAmountController,
              decoration: const InputDecoration(
                labelText: 'Monto mínimo de compra *',
                hintText: 'Ej: 50.00',
                prefixIcon: Icon(Icons.shopping_cart),
                suffixText: 'S/',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el monto mínimo';
                }
                final num = double.tryParse(value);
                if (num == null || num < 0) {
                  return 'Debe ser 0 o mayor';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Descuento máximo (solo para porcentaje)
            if (_discountType == 'PERCENTAGE')
              TextFormField(
                controller: _maximumDiscountController,
                decoration: const InputDecoration(
                  labelText: 'Descuento máximo (opcional)',
                  hintText: 'Ej: 30.00',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'S/',
                  border: OutlineInputBorder(),
                  helperText: 'Límite de descuento para cupones porcentuales',
                ),
                keyboardType: TextInputType.number,
              ),

            const SizedBox(height: 24),

            // Fecha de expiración
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha de expiración'),
              subtitle: Text(
                '${_expiresAt.day}/${_expiresAt.month}/${_expiresAt.year}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: ElevatedButton(
                onPressed: _selectExpirationDate,
                child: const Text('Cambiar'),
              ),
            ),

            const Divider(),
            const SizedBox(height: 16),

            // Límites de uso
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _usageLimitController,
                    decoration: const InputDecoration(
                      labelText: 'Límite total de usos *',
                      hintText: 'Ej: 100',
                      prefixIcon: Icon(Icons.people),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num <= 0) {
                        return 'Debe ser > 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _userUsageLimitController,
                    decoration: const InputDecoration(
                      labelText: 'Usos por usuario *',
                      hintText: 'Ej: 1',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num <= 0) {
                        return 'Debe ser > 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Estado activo/inactivo
            SwitchListTile(
              title: const Text('Cupón activo'),
              subtitle: Text(
                _isActive
                    ? 'Los usuarios podrán usar este cupón'
                    : 'El cupón estará desactivado',
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),

            const SizedBox(height: 24),

            // Botón crear
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isCreating ? null : _createCoupon,
                icon: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add_circle),
                label: Text(
                  _isCreating ? 'Creando...' : 'Crear Cupón',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

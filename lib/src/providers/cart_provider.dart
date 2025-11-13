import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/coupon_service.dart';

class CartProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final CouponService _couponService = CouponService();

  List<CartItem> _items = [];
  List<CartItem> _savedForLater = []; // NUEVO: Productos guardados para después
  Map<int, String> _productNotes =
      {}; // NUEVO: Notas por producto (productId: nota)
  List<String> _usedCoupons = []; // NUEVO: Historial de cupones usados
  int? _restaurantId;
  double _deliveryFee = 0.0;
  String? _couponCode;
  double _discount = 0.0;

  // Getters
  List<CartItem> get items => _items;
  List<CartItem> get savedForLater => _savedForLater; // NUEVO
  Map<int, String> get productNotes => _productNotes; // NUEVO
  List<String> get usedCoupons => _usedCoupons; // NUEVO
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  int? get restaurantId => _restaurantId;
  double get deliveryFee => _deliveryFee;
  String? get couponCode => _couponCode;
  double get discount => _discount;

  // Calcular subtotal
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Calcular impuesto (10%)
  double get tax {
    return subtotal * 0.10;
  }

  // Calcular subtotal con descuento
  double get subtotalWithDiscount {
    return subtotal - _discount;
  }

  // Calcular total
  double get total {
    return subtotalWithDiscount + tax + _deliveryFee;
  }

  // Verificar si el carrito está vacío
  bool get isEmpty => _items.isEmpty;

  // Cargar carrito desde storage
  Future<void> loadCart() async {
    try {
      final cartData = await _storage.read(key: 'cart');
      if (cartData != null) {
        final decoded = json.decode(cartData);
        _items = (decoded['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();

        // NUEVO: Cargar productos guardados
        if (decoded['savedForLater'] != null) {
          _savedForLater = (decoded['savedForLater'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList();
        }

        // NUEVO: Cargar notas de productos
        if (decoded['productNotes'] != null) {
          _productNotes = Map<int, String>.from(
            (decoded['productNotes'] as Map).map(
              (key, value) =>
                  MapEntry(int.parse(key.toString()), value.toString()),
            ),
          );
        }

        // NUEVO: Cargar historial de cupones
        if (decoded['usedCoupons'] != null) {
          _usedCoupons = List<String>.from(decoded['usedCoupons']);
        }

        _restaurantId = decoded['restaurantId'];
        _deliveryFee = (decoded['deliveryFee'] ?? 0.0).toDouble();
        _couponCode = decoded['couponCode'];
        _discount = (decoded['discount'] ?? 0.0).toDouble();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  // Guardar carrito en storage
  Future<void> _saveCart() async {
    try {
      final cartData = {
        'items': _items.map((item) => item.toJson()).toList(),
        'savedForLater': _savedForLater
            .map((item) => item.toJson())
            .toList(), // NUEVO
        'productNotes': _productNotes, // NUEVO
        'usedCoupons': _usedCoupons, // NUEVO
        'restaurantId': _restaurantId,
        'deliveryFee': _deliveryFee,
        'couponCode': _couponCode,
        'discount': _discount,
      };
      await _storage.write(key: 'cart', value: json.encode(cartData));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // Establecer tarifa de envío
  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    _saveCart();
    notifyListeners();
  }

  // Agregar producto al carrito
  void addItem(Product product, int quantity, {int? restaurantId}) {
    // Si el carrito tiene productos de otro restaurante, preguntar si limpiar
    if (_restaurantId != null &&
        restaurantId != null &&
        _restaurantId != restaurantId) {
      // Este caso se debe manejar en la UI con un diálogo
      return;
    }

    // Establecer el restaurante si es el primero
    if (_restaurantId == null && restaurantId != null) {
      _restaurantId = restaurantId;
    }

    // Buscar si el producto ya existe en el carrito
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Actualizar cantidad
      _items[existingIndex].quantity += quantity;
    } else {
      // Agregar nuevo item
      _items.add(CartItem(product: product, quantity: quantity));
    }

    _saveCart();
    notifyListeners();
  }

  // Actualizar cantidad de un producto
  void updateQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }

      // Si el carrito queda vacío, limpiar el restaurante
      if (_items.isEmpty) {
        _restaurantId = null;
        _deliveryFee = 0.0;
      }

      _saveCart();
      notifyListeners();
    }
  }

  // Eliminar un producto del carrito
  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);

    // Si el carrito queda vacío, limpiar el restaurante
    if (_items.isEmpty) {
      _restaurantId = null;
      _deliveryFee = 0.0;
    }

    _saveCart();
    notifyListeners();
  }

  // Incrementar cantidad
  void incrementQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      _saveCart();
      notifyListeners();
    }
  }

  // Decrementar cantidad
  void decrementQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }

      // Si el carrito queda vacío, limpiar el restaurante
      if (_items.isEmpty) {
        _restaurantId = null;
        _deliveryFee = 0.0;
      }

      _saveCart();
      notifyListeners();
    }
  }

  // Limpiar carrito completo
  Future<void> clearCart() async {
    _items = [];
    _restaurantId = null;
    _deliveryFee = 0.0;
    await _storage.delete(key: 'cart');
    notifyListeners();
  }

  // Verificar si un producto está en el carrito
  bool isInCart(int productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Obtener cantidad de un producto en el carrito
  int getProductQuantity(int productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: Product(
          id: 0,
          restaurantId: 0,
          name: '',
          description: '',
          price: 0,
          category: '',
          imageUrl: '',
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // Aplicar cupón de descuento
  Future<bool> applyCoupon(String code) async {
    // Simulación - En producción, validar con el backend
    final coupons = {
      'DESCUENTO10': 10.0, // $10 de descuento
      'PRIMERACOMPRA': 15.0, // $15 de descuento
      'VERANO2024': 20.0, // $20 de descuento
      'ESPECIAL50': subtotal * 0.5, // 50% de descuento
    };

    if (coupons.containsKey(code.toUpperCase())) {
      _couponCode = code.toUpperCase();
      _discount = coupons[code.toUpperCase()]!;
      await _markCouponAsUsed(code); // Marcar cupón como usado
      await _saveCart();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Remover cupón
  Future<void> removeCoupon() async {
    _couponCode = null;
    _discount = 0.0;
    await _saveCart();
    notifyListeners();
  }

  // ========== NUEVAS FUNCIONALIDADES ==========

  // 1. SAVE FOR LATER: Mover producto a "Guardados"
  Future<void> saveForLater(int productId) async {
    final itemIndex = _items.indexWhere((item) => item.product.id == productId);
    if (itemIndex != -1) {
      final item = _items.removeAt(itemIndex);
      _savedForLater.add(item);
      await _saveCart();
      notifyListeners();
    }
  }

  // Mover de "Guardados" al carrito
  Future<void> moveToCart(int productId) async {
    final itemIndex = _savedForLater.indexWhere(
      (item) => item.product.id == productId,
    );
    if (itemIndex != -1) {
      final item = _savedForLater.removeAt(itemIndex);
      _items.add(item);
      await _saveCart();
      notifyListeners();
    }
  }

  // Eliminar de "Guardados"
  Future<void> removeFromSaved(int productId) async {
    _savedForLater.removeWhere((item) => item.product.id == productId);
    await _saveCart();
    notifyListeners();
  }

  // 2. NOTAS PERSONALIZADAS: Agregar/actualizar nota de producto
  Future<void> setProductNote(int productId, String note) async {
    if (note.trim().isEmpty) {
      _productNotes.remove(productId);
    } else {
      _productNotes[productId] = note.trim();
    }
    await _saveCart();
    notifyListeners();
  }

  // Obtener nota de un producto
  String? getProductNote(int productId) {
    return _productNotes[productId];
  }

  // 3. HISTORIAL DE CUPONES: Marcar cupón como usado
  Future<void> _markCouponAsUsed(String code) async {
    if (!_usedCoupons.contains(code.toUpperCase())) {
      _usedCoupons.add(code.toUpperCase());
      await _saveCart();
    }
  }

  // Verificar si un cupón ya fue usado
  bool isCouponUsed(String code) {
    return _usedCoupons.contains(code.toUpperCase());
  }

  // 4. VALIDACIÓN DE CUPONES CON BACKEND (reemplaza applyCoupon hardcoded)
  Future<bool> validateCouponWithBackend(String code) async {
    try {
      // Validar con el backend usando el servicio
      final result = await _couponService.validateCoupon(
        code.toUpperCase(),
        subtotal,
      );

      if (result != null && result['valid'] == true) {
        // Cupón válido - aplicar descuento
        _couponCode = result['code'] as String?;
        _discount = (result['discount'] as num?)?.toDouble() ?? 0.0;
        await _markCouponAsUsed(code);
        await _saveCart();
        notifyListeners();
        return true;
      }

      // Cupón inválido - el mensaje de error viene en result['message']
      return false;
    } catch (e) {
      debugPrint('Error validating coupon with backend: $e');
      // Fallback a validación local si hay error de conexión
      return await applyCoupon(code);
    }
  }

  // Obtener cupones activos del backend
  Future<List<Map<String, dynamic>>> getActiveCoupons() async {
    try {
      return await _couponService.getActiveCoupons();
    } catch (e) {
      debugPrint('Error getting active coupons: $e');
      return [];
    }
  }

  // Obtener historial de cupones del backend
  Future<List<Map<String, dynamic>>> getCouponHistory() async {
    try {
      return await _couponService.getCouponHistory();
    } catch (e) {
      debugPrint('Error getting coupon history: $e');
      return [];
    }
  }

  // ========== FIN NUEVAS FUNCIONALIDADES ==========
}

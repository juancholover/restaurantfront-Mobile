import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/cart/cart_item_card.dart';
import '../../widgets/cart/product_note_dialog.dart';
import '../../widgets/cart/qr_coupon_scanner.dart';
import '../../widgets/cart/saved_item_card.dart';
import '../../widgets/cart/coupon_card.dart';
import '../checkout/checkout_screen.dart';
import '../coupons/coupon_history_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final _couponController = TextEditingController();
  bool _isApplyingCoupon = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _couponController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Carrito de Compras'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: 'Carrito (${cart.items.length})',
                  icon: const Icon(Icons.shopping_cart),
                ),
                Tab(
                  text: 'Guardados (${cart.savedForLater.length})',
                  icon: const Icon(Icons.bookmark),
                ),
              ],
            ),
            actions: [
              if (cart.items.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearCartDialog(context),
                  tooltip: 'Vaciar carrito',
                ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Carrito activo
              _buildCartTab(cart),

              // TAB 2: Guardados para después
              _buildSavedTab(cart),
            ],
          ),
        );
      },
    );
  }

  // TAB 1: Carrito activo
  Widget _buildCartTab(CartProvider cart) {
    if (cart.isEmpty) {
      return _buildEmptyCart(context);
    }

    return Column(
      children: [
        // Lista de productos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              final note = cart.getProductNote(item.product.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CartItemCard(
                  item: item,
                  note: note,
                  onIncrement: () {
                    cart.incrementQuantity(item.product.id);
                  },
                  onDecrement: () {
                    cart.decrementQuantity(item.product.id);
                  },
                  onRemove: () {
                    _showRemoveItemDialog(
                      context,
                      item.product.id,
                      item.product.name,
                    );
                  },
                  onAddNote: () async {
                    final newNote = await showDialog<String>(
                      context: context,
                      builder: (context) => ProductNoteDialog(
                        initialNote: note,
                        productName: item.product.name,
                      ),
                    );

                    if (newNote != null) {
                      cart.setProductNote(item.product.id, newNote);

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            newNote.isEmpty
                                ? 'Nota eliminada'
                                : 'Nota guardada',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  onSaveForLater: () async {
                    await cart.saveForLater(item.product.id);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${item.product.name} guardado para después',
                        ),
                        backgroundColor: Colors.orange,
                        action: SnackBarAction(
                          label: 'Deshacer',
                          textColor: Colors.white,
                          onPressed: () {
                            cart.moveToCart(item.product.id);
                          },
                        ),
                      ),
                    );

                    // Cambiar a tab de guardados
                    _tabController.animateTo(1);
                  },
                ),
              );
            },
          ),
        ),

        // Sección de cupones con QR
        _buildCouponSection(context, cart),

        // Resumen de precios
        _buildPriceSummary(context, cart),
      ],
    );
  }

  // TAB 2: Guardados para después
  Widget _buildSavedTab(CartProvider cart) {
    if (cart.savedForLater.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No tienes productos guardados',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Guarda productos para comprarlos después',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cart.savedForLater.length,
      itemBuilder: (context, index) {
        final item = cart.savedForLater[index];

        return SavedItemCard(
          item: item,
          onMoveToCart: () async {
            await cart.moveToCart(item.product.id);

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.product.name} movido al carrito'),
                backgroundColor: Colors.green,
              ),
            );

            // Cambiar a tab del carrito
            _tabController.animateTo(0);
          },
          onRemove: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar producto'),
                content: Text('¿Eliminar "${item.product.name}" de guardados?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      cart.removeFromSaved(item.product.id);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Producto eliminado'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCouponSection(BuildContext context, CartProvider cart) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.green.shade900 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.green.shade700 : Colors.green.shade200,
        ),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.local_offer,
          color: isDark ? Colors.green.shade300 : Colors.green.shade700,
        ),
        title: Text(
          cart.couponCode != null
              ? 'Cupón aplicado: ${cart.couponCode}'
              : '¿Tienes un cupón de descuento?',
          style: TextStyle(
            color: isDark ? Colors.green.shade100 : Colors.green.shade900,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cart.couponCode != null) ...[
                  // Cupón aplicado
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.green.shade800
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: isDark
                              ? Colors.green.shade300
                              : Colors.green.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cupón ${cart.couponCode}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.green.shade100
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                'Descuento: \$${cart.discount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.green.shade200
                                      : Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            cart.removeCoupon();
                            _couponController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cupón eliminado'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Input para aplicar cupón con botón QR
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          textCapitalization: TextCapitalization.characters,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ingresa tu código',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey.shade800
                                : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.qr_code_scanner),
                              onPressed: () async {
                                final scannedCode = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const QRCouponScanner(),
                                  ),
                                );

                                if (scannedCode != null) {
                                  _couponController.text = scannedCode;
                                  if (!mounted) return;
                                  _applyCoupon(cart);
                                }
                              },
                              tooltip: 'Escanear código QR',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isApplyingCoupon
                            ? null
                            : () {
                                _applyCoupon(cart);
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isApplyingCoupon
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Aplicar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Cupones disponibles (demo)
                  Text(
                    'Cupones disponibles:',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade300 : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildCouponChip('DESCUENTO10', '\$10 OFF', isDark, cart),
                      _buildCouponChip(
                        'PRIMERACOMPRA',
                        '\$15 OFF',
                        isDark,
                        cart,
                      ),
                      _buildCouponChip('VERANO2024', '\$20 OFF', isDark, cart),
                      _buildCouponChip('ESPECIAL50', '50% OFF', isDark, cart),
                    ],
                  ),
                ],

                // Historial de cupones usados
                if (cart.usedCoupons.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.history,
                      color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                      size: 20,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Historial de cupones usados (${cart.usedCoupons.length})',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CouponHistoryScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Ver todo'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      ...cart.usedCoupons.map((code) {
                        final isCurrentCoupon = cart.couponCode == code;

                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          leading: Icon(
                            isCurrentCoupon
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: isCurrentCoupon ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          title: Text(
                            code,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrentCoupon
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey[700],
                            ),
                          ),
                          trailing: isCurrentCoupon
                              ? Chip(
                                  label: const Text(
                                    'Activo',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.green.shade100,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                )
                              : Text(
                                  'Usado',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                        );
                      }),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponChip(
    String code,
    String description,
    bool isDark,
    CartProvider cart,
  ) {
    final isUsed = cart.isCouponUsed(code);
    final isActive = cart.couponCode == code;

    return InkWell(
      onTap: isUsed && !isActive
          ? null
          : () {
              _couponController.text = code;
            },
      child: Opacity(
        opacity: (isUsed && !isActive) ? 0.5 : 1.0,
        child: Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$code - $description',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.green.shade100 : Colors.green.shade900,
                ),
              ),
              if (isUsed && !isActive) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.green.shade700,
                ),
              ],
            ],
          ),
          backgroundColor: isDark
              ? Colors.green.shade800
              : Colors.green.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
    );
  }

  void _applyCoupon(CartProvider cart) async {
    final code = _couponController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un código de cupón'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar si el cupón ya fue usado
    if (cart.isCouponUsed(code) && cart.couponCode != code.toUpperCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El cupón "$code" ya fue utilizado anteriormente'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isApplyingCoupon = true);

    final success = await cart.validateCouponWithBackend(code);

    setState(() => _isApplyingCoupon = false);

    if (success) {
      _couponController.clear();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Cupón "$code" aplicado! Descuento: S/${cart.discount.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Cupón "$code" no válido o ya expiró')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Ver cupones',
            textColor: Colors.white,
            onPressed: () => _showAvailableCoupons(),
          ),
        ),
      );
    }
  }

  // Mostrar cupones disponibles
  Future<void> _showAvailableCoupons() async {
    final cart = context.read<CartProvider>();
    final coupons = await cart.getActiveCoupons();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Cupones Disponibles',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Lista de cupones
            Expanded(
              child: coupons.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.discount_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay cupones disponibles',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: coupons.length,
                      itemBuilder: (context, index) {
                        final coupon = coupons[index];

                        return CouponCard(
                          couponData: coupon,
                          onTap: () {
                            Navigator.pop(context);
                            _couponController.text = coupon['code'];
                            final cart = context.read<CartProvider>();
                            _applyCoupon(cart);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Agrega productos para continuar',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar al home
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Explorar Restaurantes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context, CartProvider cart) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPriceRow('Subtotal', cart.subtotal),
              const SizedBox(height: 8),

              // Descuento (si hay cupón aplicado)
              if (cart.discount > 0) ...[
                _buildPriceRow(
                  'Descuento (${cart.couponCode})',
                  -cart.discount,
                  isDiscount: true,
                ),
                const SizedBox(height: 8),
              ],

              // Delivery
              _buildPriceRow('Envío', cart.deliveryFee),
              const SizedBox(height: 8),

              // Impuesto
              _buildPriceRow('Impuesto (10%)', cart.tax),

              const Divider(height: 24),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${cart.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Botón continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar con el pago',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDiscount ? Colors.green[700] : Colors.grey[700],
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDiscount ? Colors.green[700] : Colors.black,
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todos los productos del carrito?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }

  void _showRemoveItemDialog(
    BuildContext context,
    int productId,
    String productName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Quieres eliminar "$productName" del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartProvider>().removeItem(productId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

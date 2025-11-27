import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../admin/admin_coupon_screen.dart';

/// Dashboard principal del administrador
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _activeCoupons = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();

      try {
        // Intentar cargar estadísticas reales
        debugPrint('📊 Cargando estadísticas del dashboard...');
        final statsResponse = await apiService.get(
          '/admin/stats',
          requiresAuth: true,
        );

        debugPrint('✅ Estadísticas recibidas:');
        debugPrint('   Success: ${statsResponse['success']}');
        debugPrint('   Data: ${statsResponse['data']}');

        if (mounted) {
          setState(() {
            _stats = statsResponse['data'] ?? {};
          });
        }
      } catch (e) {
        debugPrint('⚠️ Endpoint /admin/stats no disponible: $e');
        debugPrint('⚠️ Usando datos mock');
        if (mounted) {
          setState(() {
            _stats = {
              'totalOrders': 12,
              'totalRevenue': 1250.50,
              'activeUsers': 45,
              'totalProducts': 28,
            };
          });
        }
      }

      try {
        // Intentar cargar órdenes recientes
        debugPrint('📦 Cargando pedidos recientes...');
        final ordersResponse = await apiService.get(
          '/admin/recent-orders',
          requiresAuth: true,
        );

        debugPrint('✅ Pedidos recientes recibidos:');
        debugPrint('   Success: ${ordersResponse['success']}');
        debugPrint(
          '   Count: ${(ordersResponse['data'] as List?)?.length ?? 0}',
        );

        if (mounted) {
          setState(() {
            _recentOrders = List<Map<String, dynamic>>.from(
              ordersResponse['data'] ?? [],
            );
          });
        }
      } catch (e) {
        debugPrint('⚠️ Endpoint /admin/recent-orders no disponible: $e');
        debugPrint('⚠️ Usando datos mock');
        if (mounted) {
          setState(() {
            _recentOrders = [];
          });
        }
      }

      try {
        // Intentar cargar cupones activos
        final couponsResponse = await apiService.get(
          '/admin/active-coupons',
          requiresAuth: true,
        );

        if (mounted) {
          setState(() {
            _activeCoupons = List<Map<String, dynamic>>.from(
              couponsResponse['data'] ?? [],
            );
          });
        }
      } catch (e) {
        debugPrint(
          '⚠️ Endpoint /admin/active-coupons no disponible, usando datos mock',
        );
        if (mounted) {
          setState(() {
            _activeCoupons = [];
          });
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Error general en dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar dashboard'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];

    return '$weekday, ${now.day} de $month ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: AppTheme.primaryOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta de bienvenida
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),

                    // Estadísticas principales
                    const Text(
                      'Estadísticas del Día',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatisticsGrid(),
                    const SizedBox(height: 24),

                    // Acciones rápidas
                    const Text(
                      'Acciones Rápidas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 24),

                    // Órdenes recientes
                    const Text(
                      'Pedidos Recientes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentOrders(),
                    const SizedBox(height: 24),

                    // Cupones activos
                    const Text(
                      'Cupones Activos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActiveCoupons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.primaryOrange,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Bienvenido, Admin!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrentDate(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    final todayOrders = (_stats['todayOrders'] ?? 0) as int;
    final todaySales = ((_stats['todaySales'] ?? 0.0) as num).toDouble();
    final activeUsers = (_stats['activeUsers'] ?? 0) as int;
    final pendingOrders = (_stats['pendingOrders'] ?? 0) as int;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          'Pedidos Hoy',
          todayOrders.toString(),
          Icons.shopping_bag,
          Colors.blue,
        ),
        _buildStatCard(
          'Ventas Hoy',
          '\$${todaySales.toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'Usuarios Activos',
          activeUsers.toString(),
          Icons.people,
          Colors.purple,
        ),
        _buildStatCard(
          'Pedidos Pendientes',
          pendingOrders.toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Crear Cupón',
            Icons.local_offer,
            Colors.orange,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminCouponScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Gestionar Pedidos',
            Icons.list_alt,
            Colors.blue,
            () {
              // Navegar a la pantalla de historial de pedidos (admin puede ver todos)
              Navigator.pushNamed(context, '/order-history');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    if (_recentOrders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No hay pedidos recientes',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: _recentOrders.take(5).map((order) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order['status']),
              child: const Icon(Icons.receipt, color: Colors.white, size: 20),
            ),
            title: Text('Pedido #${order['id']}'),
            subtitle: Text(order['restaurantName'] ?? 'Restaurante'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${order['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusLabel(order['status']),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(order['status']),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/order-detail',
                arguments: order['id'],
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActiveCoupons() {
    if (_activeCoupons.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.local_offer, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No hay cupones activos',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminCouponScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Cupón'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: _activeCoupons.take(5).map((coupon) {
        final usageCount = (coupon['usageCount'] ?? 0) as num;
        final usageLimit = (coupon['usageLimit'] ?? 1) as num;
        final usagePercent = usageLimit > 0
            ? (usageCount / usageLimit) * 100
            : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primaryOrange,
              child: Icon(Icons.local_offer, color: Colors.white, size: 20),
            ),
            title: Text(
              coupon['code'] ?? 'CUPÓN',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coupon['description'] ?? ''),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: usagePercent / 100,
                  backgroundColor: Colors.grey[200],
                  color: AppTheme.primaryOrange,
                ),
                const SizedBox(height: 4),
                Text(
                  '${usageCount.toInt()}/${usageLimit.toInt()} usos',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Switch(
              value: coupon['isActive'] ?? false,
              onChanged: (value) {
                _toggleCouponStatus(coupon['id'], value);
              },
              activeThumbColor: AppTheme.primaryOrange,
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'on_the_way':
      case 'ontheway':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'Preparando';
      case 'ready':
        return 'Listo';
      case 'on_the_way':
      case 'ontheway':
        return 'En camino';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  Future<void> _toggleCouponStatus(int couponId, bool isActive) async {
    try {
      final apiService = ApiService();
      await apiService.put('/admin/coupons/$couponId/toggle', {
        'isActive': isActive,
      }, requiresAuth: true);

      setState(() {
        final coupon = _activeCoupons.firstWhere((c) => c['id'] == couponId);
        coupon['isActive'] = isActive;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isActive ? '✅ Cupón activado' : '❌ Cupón desactivado',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

import 'package:share_plus/share_plus.dart';
import '../models/restaurant.dart';
import '../models/order.dart';

class ShareService {
  // Compartir restaurante
  static Future<void> shareRestaurant(Restaurant restaurant) async {
    final text =
        '''
🍽️ ¡Mira este restaurante!

${restaurant.name}
⭐ ${restaurant.rating.toStringAsFixed(1)} estrellas
🕐 ${restaurant.deliveryTime} min
${restaurant.categories.join(', ')}

${restaurant.description}

¡Descárgala app y pide ahora!
''';

    await Share.share(text, subject: '¡Te recomiendo ${restaurant.name}!');
  }

  // Compartir pedido
  static Future<void> shareOrder(Order order) async {
    final text =
        '''
📦 Mi pedido en ${order.restaurantName}

Pedido #${order.id}
💰 Total: \$${order.totalAmount.toStringAsFixed(2)}
📍 ${order.deliveryAddress}

¡Ordena tú también desde la app!
''';

    await Share.share(text, subject: 'Mi pedido en ${order.restaurantName}');
  }

  // Compartir app
  static Future<void> shareApp() async {
    const text = '''
🍕 ¡Descarga nuestra app de delivery!

Pide comida de tus restaurantes favoritos con:
✅ Entregas rápidas
✅ Cupones de descuento
✅ Tracking en tiempo real
✅ Múltiples métodos de pago

¡Descárgala ahora!
''';

    await Share.share(text, subject: '¡Prueba nuestra app de delivery!');
  }
}

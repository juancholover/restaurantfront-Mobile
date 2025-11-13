import 'package:flutter/material.dart';
import '../../models/cart_item.dart';

class SavedItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onMoveToCart;
  final VoidCallback onRemove;

  const SavedItemCard({
    super.key,
    required this.item,
    required this.onMoveToCart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.grey.withOpacity(0.3),
                      BlendMode.saturation,
                    ),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.fastfood,
                            size: 32,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Precio
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Cantidad guardada
                  Text(
                    'Cantidad guardada: ${item.quantity}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onMoveToCart,
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 16,
                          ),
                          label: const Text(
                            'Mover al carrito',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

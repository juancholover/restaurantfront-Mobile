import 'package:flutter/material.dart';
import '../../models/cart_item.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final VoidCallback? onAddNote; // NUEVO
  final VoidCallback? onSaveForLater; // NUEVO
  final String? note; // NUEVO

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    this.onAddNote,
    this.onSaveForLater,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(item.product.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white, size: 32),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Eliminar producto'),
              content: Text(
                '¿Quieres eliminar "${item.product.name}" del carrito?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          onRemove();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
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

                    // Precio unitario
                    Text(
                      '\$${item.product.price.toStringAsFixed(2)} c/u',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),

                    // NUEVO: Mostrar nota si existe
                    if (note != null && note!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.note,
                              size: 14,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                note!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade900,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // NUEVO: Botones de acción
                    Row(
                      children: [
                        if (onAddNote != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onAddNote,
                              icon: Icon(
                                note != null && note!.isNotEmpty
                                    ? Icons.edit_note
                                    : Icons.note_add,
                                size: 16,
                              ),
                              label: Text(
                                note != null && note!.isNotEmpty
                                    ? 'Editar nota'
                                    : 'Agregar nota',
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ),
                        if (onAddNote != null && onSaveForLater != null)
                          const SizedBox(width: 8),
                        if (onSaveForLater != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onSaveForLater,
                              icon: const Icon(Icons.bookmark_add, size: 16),
                              label: const Text(
                                'Guardar',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Controles de cantidad
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botones +/-
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: onDecrement,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: onIncrement,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Precio total
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

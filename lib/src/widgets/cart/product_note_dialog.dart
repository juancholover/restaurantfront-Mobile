import 'package:flutter/material.dart';

class ProductNoteDialog extends StatefulWidget {
  final String? initialNote;
  final String productName;

  const ProductNoteDialog({
    super.key,
    this.initialNote,
    required this.productName,
  });

  @override
  State<ProductNoteDialog> createState() => _ProductNoteDialogState();
}

class _ProductNoteDialogState extends State<ProductNoteDialog> {
  late TextEditingController _controller;
  final _maxLength = 200;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.note_add, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nota para\n${widget.productName}',
              style: const TextStyle(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agrega instrucciones especiales (ej: sin cebolla, extra picante, etc.)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLength: _maxLength,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Escribe tu nota aquí...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              counterText: '${_controller.text.length}/$_maxLength',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'La nota se enviará con tu pedido',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (widget.initialNote != null && widget.initialNote!.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.pop(context, ''), // Eliminar nota
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

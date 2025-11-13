import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

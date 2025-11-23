import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar mensajes de error.
///
/// Este widget proporciona una visualización consistente de mensajes
/// de error con un diseño destacado y fácil de identificar.
class ErrorMessageBox extends StatelessWidget {
  /// Mensaje de error a mostrar
  final String message;

  const ErrorMessageBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }
}

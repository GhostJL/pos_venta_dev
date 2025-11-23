import 'package:flutter/material.dart';

/// Widget reutilizable para campos de entrada de dinero.
///
/// Este widget proporciona un campo de texto especializado para
/// entrada de valores monetarios con formato consistente.
class MoneyInputField extends StatelessWidget {
  /// Controlador del campo de texto
  final TextEditingController controller;

  /// Etiqueta del campo (opcional)
  final String? label;

  /// Texto de ayuda debajo del campo (opcional)
  final String? helpText;

  /// Si el campo debe tener autofocus
  final bool autofocus;

  /// Texto del hint (por defecto: "0.00")
  final String hintText;

  const MoneyInputField({
    super.key,
    required this.controller,
    this.label,
    this.helpText,
    this.autofocus = false,
    this.hintText = '0.00',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          autofocus: autofocus,
        ),
        if (helpText != null) ...[
          const SizedBox(height: 8),
          Text(
            helpText!,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}

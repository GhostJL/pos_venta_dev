import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/purchase.dart';

/// Widget reutilizable para mostrar el diálogo de confirmación de cancelación de compra.
///
/// Muestra un diálogo de confirmación que:
/// - Pregunta si desea cancelar la compra
/// - Muestra advertencia si la compra tiene items recibidos
/// - Retorna true si el usuario confirma, false o null si cancela
class PurchaseCancelDialog {
  static Future<bool?> show({
    required BuildContext context,
    required Purchase purchase,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cancelar Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Está seguro de cancelar la compra #${purchase.purchaseNumber}?',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: cs.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Esta acción cancelará la orden de compra permanentemente.',
                      style: TextStyle(
                        color: cs.onErrorContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('No, Salir'),
          ),
          FilledButton.tonal(
            onPressed: () => context.pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.errorContainer,
              foregroundColor: cs.onErrorContainer,
            ),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }
}

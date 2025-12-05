import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
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
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Está seguro de cancelar la compra #${purchase.purchaseNumber}?',
            ),
            if (purchase.status == PurchaseStatus.partial ||
                purchase.status == PurchaseStatus.completed) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.transactionPending,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Esta compra tiene items recibidos. Al cancelar, se revertirá el inventario recibido.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('No, Salir'),
          ),
          ElevatedButton.icon(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            icon: const Icon(Icons.cancel),
            label: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/presentation/providers/purchase_item_providers.dart';
import 'package:posventa/presentation/widgets/purchases/items/purchase_item_detail/purchase_item_header.dart';
import 'package:posventa/presentation/widgets/purchases/items/purchase_item_detail/purchase_item_info_section.dart';
import 'package:posventa/presentation/widgets/purchases/items/purchase_item_detail/purchase_item_financial_section.dart';
import 'package:posventa/presentation/widgets/purchases/items/purchase_item_detail/purchase_item_metadata_section.dart';

/// Detailed view of a single purchase item
/// Shows all information including related purchase and product details
class PurchaseItemDetailPage extends ConsumerWidget {
  final int itemId;

  const PurchaseItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(purchaseItemByIdProvider(itemId));
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Artículo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, ref),
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: itemAsync.when(
        data: (item) {
          if (item == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Artículo no encontrado',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                PurchaseItemHeader(item: item),

                const SizedBox(height: 20),

                // Product Information Section
                PurchaseItemInfoSection(item: item, dateFormat: dateFormat),

                const SizedBox(height: 20),

                // Financial Information Section
                PurchaseItemFinancialSection(item: item),

                const SizedBox(height: 20),

                // Metadata Section
                PurchaseItemMetadataSection(item: item, dateFormat: dateFormat),

                const SizedBox(height: 24),

                // Action Buttons
                if (item.purchaseId != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/purchases/${item.purchaseId}');
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver Compra Completa'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text(
          '¿Está seguro de que desea eliminar este artículo de compra? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop(dialogContext);
              try {
                await ref
                    .read(purchaseItemProvider.notifier)
                    .deletePurchaseItem(itemId);
                if (context.mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Artículo eliminado exitosamente'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

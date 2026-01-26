import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/inventory_audit.dart';
import 'package:posventa/presentation/providers/inventory/inventory_audit_view_model.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_scan_widget.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_audit_search_delegate.dart';

class InventoryAuditMobilePage extends ConsumerWidget {
  const InventoryAuditMobilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAuditAsync = ref.watch(inventoryAuditViewModelProvider);
    final auditListAsync = ref.watch(inventoryAuditListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Inventario Físico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              if (activeAuditAsync.value != null) {
                final selectedItem = await showSearch(
                  context: context,
                  delegate: InventoryAuditSearchDelegate(
                    activeAuditAsync.value!.items,
                  ),
                );
                if (selectedItem != null && context.mounted) {
                  _showEditCountDialog(context, ref, selectedItem);
                }
              }
            },
          ),
          if (activeAuditAsync.value == null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(inventoryAuditListProvider),
            ),
        ],
      ),
      body: activeAuditAsync.when(
        data: (activeAudit) {
          if (activeAudit == null) {
            return _buildAuditList(context, ref, auditListAsync);
          }
          return _buildActiveAudit(context, ref, activeAudit);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: activeAuditAsync.value == null
          ? FloatingActionButton.extended(
              onPressed: () => _showStartAuditDialog(context, ref),
              label: const Text('Nueva Toma'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildAuditList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<InventoryAuditEntity>> auditListAsync,
  ) {
    return auditListAsync.when(
      data: (audits) {
        if (audits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                const Text('No hay tomas de inventario registradas'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: audits.length,
          itemBuilder: (context, index) {
            final audit = audits[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.inventory)),
              title: Text(
                '#${audit.id} - ${DateFormat('dd/MM/yyyy').format(audit.auditDate)}',
              ),
              subtitle: Text(audit.status.name.toUpperCase()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ref
                  .read(inventoryAuditViewModelProvider.notifier)
                  .loadAudit(audit.id!),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildActiveAudit(
    BuildContext context,
    WidgetRef ref,
    InventoryAuditEntity audit,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final countedItems = audit.items
        .where((i) => i.countedQuantity > 0)
        .toList();
    final progress = audit.items.isEmpty
        ? 0.0
        : countedItems.length / audit.items.length;

    return Column(
      children: [
        // Header Info
        Container(
          color: colorScheme.surfaceContainer,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Almacén ${audit.warehouseId}',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '${countedItems.length} / ${audit.items.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              InventoryScanWidget(
                onScan: (barcode) async {
                  try {
                    await ref
                        .read(inventoryAuditViewModelProvider.notifier)
                        .scanProduct(barcode);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: colorScheme.error,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),

        // Items List
        Expanded(
          child: countedItems.isEmpty
              ? const Center(child: Text('Escanea productos para comenzar'))
              : ListView.builder(
                  itemCount: countedItems.length,
                  itemBuilder: (context, index) {
                    final item = countedItems[index];
                    final diff = item.difference;
                    final diffColor = diff == 0
                        ? Colors.green
                        : (diff > 0 ? Colors.blue : Colors.red);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(item.productName ?? 'Desconocido'),
                        subtitle: Text('${item.barcode}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.countedQuantity} / ${item.expectedQuantity}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              diff >= 0 ? '+$diff' : '$diff',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: diffColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onLongPress: () =>
                            _showEditCountDialog(context, ref, item),
                      ),
                    );
                  },
                ),
        ),

        // Footer Actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(inventoryAuditViewModelProvider),
                  child: const Text('Salir'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () => _confirmCompleteAudit(context, ref),
                  child: const Text('Finalizar'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showStartAuditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Toma'),
        content: const Text(
          '¿Iniciar nueva toma de inventario? Se capturará el stock actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(inventoryAuditViewModelProvider.notifier)
                  .startNewAudit(1);
              Navigator.pop(context);
            },
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }

  void _showEditCountDialog(
    BuildContext context,
    WidgetRef ref,
    InventoryAuditItemEntity item,
  ) {
    final controller = TextEditingController(
      text: item.countedQuantity.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar: ${item.productName}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final count = double.tryParse(controller.text) ?? 0.0;
              ref
                  .read(inventoryAuditViewModelProvider.notifier)
                  .updateItemCount(item.id!, count);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmCompleteAudit(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Finalizar y Ajustar?'),
        content: const Text(
          'El stock del sistema será actualizado. Esta acción es irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(inventoryAuditViewModelProvider.notifier)
                  .completeAudit();
              Navigator.pop(context);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/inventory_audit.dart';
import 'package:posventa/presentation/providers/inventory/inventory_audit_view_model.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_audit_search_delegate.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_scan_widget.dart';

class InventoryAuditMobilePage extends ConsumerWidget {
  const InventoryAuditMobilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAuditAsync = ref.watch(inventoryAuditViewModelProvider);
    final theme = Theme.of(context);

    // If no active audit is selected/loaded, show the history list
    return activeAuditAsync.when(
      data: (audit) {
        if (audit == null) {
          return _buildAuditHistoryList(context, ref);
        }
        return _buildActiveAuditView(context, ref, audit);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildAuditHistoryList(BuildContext context, WidgetRef ref) {
    final auditListAsync = ref.watch(inventoryAuditListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Auditorías de Inventario')),
      drawer: NavigationDrawer(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Usuario'),
            accountEmail: Text('admin@pos.com'),
            currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventario'),
            onTap: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartAuditDialog(context, ref),
        label: const Text('Nueva'),
        icon: const Icon(Icons.add),
      ),
      body: auditListAsync.when(
        data: (audits) {
          if (audits.isEmpty) {
            return const Center(child: Text('No hay auditorías registradas'));
          }
          return ListView.builder(
            itemCount: audits.length,
            itemBuilder: (context, index) {
              final audit = audits[index];
              return ListTile(
                leading: CircleAvatar(child: Text('#${audit.id}')),
                title: Text(
                  DateFormat(
                    'dd MMM yyyy, HH:mm',
                    'es',
                  ).format(audit.auditDate),
                ),
                subtitle: Text(
                  audit.status.name.toUpperCase(),
                  style: TextStyle(
                    color: audit.status.name == 'completed'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ref
                      .read(inventoryAuditViewModelProvider.notifier)
                      .loadAudit(audit.id!);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildActiveAuditView(
    BuildContext context,
    WidgetRef ref,
    InventoryAuditEntity audit,
  ) {
    final theme = Theme.of(context);
    final isLocked = audit.status == InventoryAuditStatus.completed;

    // Sort items: Counted first, then pending? Or just by ID
    // Let's show counted at top for easier verification
    final sortedItems = List<InventoryAuditItemEntity>.from(audit.items);
    sortedItems.sort((a, b) {
      if (a.countedQuantity > 0 && b.countedQuantity == 0) return -1;
      if (a.countedQuantity == 0 && b.countedQuantity > 0) return 1;
      return 0;
    });

    final totalCounted = audit.items.where((i) => i.countedQuantity > 0).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.invalidate(inventoryAuditViewModelProvider),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auditoría #${audit.id}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Almacén ${audit.warehouseId}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // If locked, don't show search or edit actions the same way
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar por nombre',
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: InventoryAuditSearchDelegate(audit.items),
              );
              if (result != null && !isLocked) {
                if (context.mounted) {
                  _showEditCountDialog(context, ref, result);
                }
              }
            },
          ),
          if (!isLocked)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Finalizar',
              onPressed: () => _confirmCompleteAudit(context, ref),
            ),
          if (isLocked)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.lock, color: Colors.white70),
            ),
        ],
      ),
      body: Column(
        children: [
          // Banner for status
          Container(
            padding: const EdgeInsets.all(12),
            color: isLocked
                ? Colors.green.shade100
                : theme.colorScheme.surfaceContainerHighest,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso: $totalCounted / ${audit.items.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  isLocked ? 'FINALIZADA' : 'EN PROCESO',
                  style: TextStyle(
                    color: isLocked ? Colors.green[800] : Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          if (!isLocked)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InventoryScanWidget(
                hint: 'Escanear para sumar (+1)',
                onScan: (barcode) async {
                  try {
                    await ref
                        .read(inventoryAuditViewModelProvider.notifier)
                        .scanProduct(barcode);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Producto +1'),
                          duration: Duration(milliseconds: 500),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  }
                },
              ),
            ),

          Expanded(
            child: ListView.separated(
              itemCount: sortedItems.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = sortedItems[index];
                final diff = item.difference;
                final bool hasCount = item.countedQuantity > 0;

                return ListTile(
                  tileColor: hasCount
                      ? theme.colorScheme.surfaceContainerLow
                      : null,
                  leading: const CircleAvatar(
                    child: Icon(Icons.inventory_2_outlined),
                  ),
                  title: Text(
                    item.variantName != null
                        ? '${item.productName} - ${item.variantName}'
                        : item.productName ?? 'Desconocido',
                  ),
                  subtitle: Text('Código: ${item.barcode ?? 'N/A'}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.countedQuantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sis: ${item.expectedQuantity}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: isLocked
                      ? null
                      : () => _showEditCountDialog(context, ref, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStartAuditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Auditoría'),
        content: const Text('Se iniciará una nueva toma de inventario.'),
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
            child: const Text('Confirmar'),
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
      text: item.countedQuantity.toString().replaceAll(
        '.0',
        '',
      ), // Remove decimal if whole
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.productName ?? 'Editar Cantidad'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Cantidad Física',
            border: OutlineInputBorder(),
          ),
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
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Finalizar?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'El inventario se ajustará a lo contado. Esta acción no se puede deshacer.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo / Nota (Opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
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
                  .completeAudit(reason: reasonController.text);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}

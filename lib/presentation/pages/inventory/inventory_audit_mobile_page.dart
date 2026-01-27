import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/inventory_audit.dart';
import 'package:posventa/presentation/providers/inventory/inventory_audit_view_model.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_audit_search_delegate.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_scan_widget.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_audit_pdf_builder.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/store_provider.dart';
import 'package:posventa/presentation/widgets/menu/side_menu.dart';

class InventoryAuditMobilePage extends ConsumerWidget {
  const InventoryAuditMobilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAuditAsync = ref.watch(inventoryAuditViewModelProvider);

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
      appBar: AppBar(
        title: const Text('Auditorias'),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: const SideMenu(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartAuditDialog(context, ref),
        label: const Text('Nueva'),
        icon: const Icon(Icons.add),
      ),
      body: auditListAsync.when(
        data: (audits) {
          if (audits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay auditorías registradas',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: audits.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final audit = audits[index];
              return _buildAuditHistoryCard(context, ref, audit);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildAuditHistoryCard(
    BuildContext context,
    WidgetRef ref,
    InventoryAuditEntity audit,
  ) {
    final theme = Theme.of(context);
    final isCompleted = audit.status == InventoryAuditStatus.completed;
    final color = isCompleted ? Colors.green : Colors.orange;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => ref
            .read(inventoryAuditViewModelProvider.notifier)
            .loadAudit(audit.id!),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Folio #${audit.id}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isCompleted ? 'FINALIZADA' : 'EN PROCESO',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat(
                      'dd MMM yyyy, HH:mm',
                      'es',
                    ).format(audit.auditDate),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
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

    // Sorting: Counted first for visibility
    final sortedItems = List<InventoryAuditItemEntity>.from(audit.items);
    sortedItems.sort((a, b) {
      // Prioritize showing items that have been counted
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: InventoryAuditSearchDelegate(audit.items),
              );
              if (result != null && !isLocked && context.mounted) {
                _showEditCountDialog(context, ref, result);
              }
            },
          ),
          if (!isLocked)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Finalizar',
              onPressed: () => _confirmCompleteAudit(context, ref),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') _viewReport(context, ref, audit);
              if (value == 'copy') _confirmFillStock(context, ref);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Ver Reporte'),
                  ],
                ),
              ),
              if (!isLocked)
                const PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Icons.copy_all, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Copiar Stock Sistema'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progreso: $totalCounted / ${audit.items.length}'),
                Text(
                  isLocked ? 'FINALIZADA' : 'EN PROCESO',
                  style: TextStyle(
                    color: isLocked ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Scan Area (Only if active)
          if (!isLocked)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InventoryScanWidget(
                hint: 'Escanear producto...',
                onScan: (barcode) async {
                  try {
                    await ref
                        .read(inventoryAuditViewModelProvider.notifier)
                        .scanProduct(barcode);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Agregado +1'),
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

          // Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedItems.length,
              separatorBuilder: (c, i) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = sortedItems[index];
                return _buildAuditItemCard(context, ref, item, isLocked);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditItemCard(
    BuildContext context,
    WidgetRef ref,
    InventoryAuditItemEntity item,
    bool isLocked,
  ) {
    final theme = Theme.of(context);
    final hasCount = item.countedQuantity > 0;
    final diff = item.difference;
    final isMatch = diff == 0;
    final diffColor = isMatch
        ? Colors.green
        : (diff > 0 ? Colors.blue : Colors.red);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasCount
              ? theme.primaryColor.withValues(alpha: 0.5)
              : theme.dividerColor,
        ),
      ),
      color: hasCount ? theme.primaryColor.withValues(alpha: 0.05) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLocked ? null : () => _showEditCountDialog(context, ref, item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_outlined),
              ),
              const SizedBox(width: 12),
              // Name & Code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.variantName != null
                          ? '${item.productName} - ${item.variantName}'
                          : item.productName ?? 'Desconocido',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${item.barcode ?? 'N/A'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Quantities
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.countedQuantity}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Sis: ${item.expectedQuantity}',
                    style: TextStyle(fontSize: 10, color: theme.hintColor),
                  ),
                  if (hasCount && !isMatch)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        diff > 0 ? '+$diff' : '$diff',
                        style: TextStyle(
                          color: diffColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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
      text: item.countedQuantity.toString().replaceAll('.0', ''),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.productName ?? 'Editar'),
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

  void _confirmFillStock(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Copiar Stock?'),
        content: const Text(
          'El stock físico será igual al del sistema para todos los productos.',
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
                  .fillWithSystemStock();
              Navigator.pop(context);
            },
            child: const Text('Copiar'),
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
        title: const Text('¿Finalizar Auditoría?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('El inventario se ajustará permanentemente.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo / Nota',
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
            onPressed: () async {
              Navigator.pop(context);

              final completedAudit = await ref
                  .read(inventoryAuditViewModelProvider.notifier)
                  .completeAudit(reason: reasonController.text);

              if (completedAudit != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Auditoría finalizada. Generando reporte...'),
                    backgroundColor: Colors.green,
                  ),
                );
                _viewReport(context, ref, completedAudit);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _viewReport(
    BuildContext context,
    WidgetRef ref,
    InventoryAuditEntity audit,
  ) async {
    final user = ref.read(authProvider).user;
    final userName = user?.name ?? 'Usuario #${user?.id}';
    final store = await ref.read(storeProvider.future);

    await InventoryAuditPdfBuilder.generateAndOpen(
      audit: audit,
      store: store,
      warehouseName: 'Almacén Principal',
      userName: userName,
      title: audit.status == InventoryAuditStatus.completed
          ? 'Reporte Final de Auditoría'
          : 'Reporte Preliminar',
    );
  }
}

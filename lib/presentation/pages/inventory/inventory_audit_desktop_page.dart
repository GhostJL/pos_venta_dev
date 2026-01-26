import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/inventory_audit.dart';
import 'package:posventa/presentation/providers/inventory/inventory_audit_view_model.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_scan_widget.dart';

class InventoryAuditDesktopPage extends ConsumerStatefulWidget {
  const InventoryAuditDesktopPage({super.key});

  @override
  ConsumerState<InventoryAuditDesktopPage> createState() =>
      _InventoryAuditDesktopPageState();
}

class _InventoryAuditDesktopPageState
    extends ConsumerState<InventoryAuditDesktopPage> {
  final TextEditingController _filterController = TextEditingController();
  String _filterText = '';

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Panel: Audit History List
          SizedBox(width: 350, child: _buildSidebar(context, ref)),
          const VerticalDivider(width: 1),
          // Right Panel: Active Audit Details
          Expanded(child: _buildMainContent(context, ref)),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref) {
    final auditListAsync = ref.watch(inventoryAuditListProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Historial', style: theme.textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(inventoryAuditListProvider),
                tooltip: 'Recargar lista',
              ),
            ],
          ),
        ),
        Expanded(
          child: auditListAsync.when(
            data: (audits) {
              if (audits.isEmpty) {
                return const Center(child: Text('Sin registros'));
              }
              return ListView.separated(
                itemCount: audits.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final audit = audits[index];
                  final isSelected =
                      ref.watch(inventoryAuditViewModelProvider).value?.id ==
                      audit.id;

                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer
                        .withOpacity(0.2),
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      child: Text('#${audit.id}'),
                    ),
                    title: Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(audit.auditDate),
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
                    onTap: () {
                      ref
                          .read(inventoryAuditViewModelProvider.notifier)
                          .loadAudit(audit.id!);
                      _filterController.clear();
                      setState(() {
                        _filterText = '';
                      });
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showStartAuditDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Nueva Toma de Inventario'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, WidgetRef ref) {
    final activeAuditAsync = ref.watch(inventoryAuditViewModelProvider);

    return activeAuditAsync.when(
      data: (audit) {
        if (audit == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 96,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Seleccione una toma de inventario o inicie una nueva',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }
        return _buildActiveAuditView(context, ref, audit);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildActiveAuditView(
    BuildContext context,
    WidgetRef ref,
    InventoryAuditEntity audit,
  ) {
    final theme = Theme.of(context);

    // Apply local filter
    final filteredItems = audit.items.where((item) {
      if (_filterText.isEmpty) return true;
      final term = _filterText.toLowerCase();
      final name = item.productName?.toLowerCase() ?? '';
      final variant = item.variantName?.toLowerCase() ?? '';
      final barcode = item.barcode?.toLowerCase() ?? '';

      return name.contains(term) ||
          variant.contains(term) ||
          barcode.contains(term);
    }).toList();

    // Separate into Counted vs Pending only if NO filter is active
    // If filter is active, show all matches to find them easily
    final showAll = _filterText.isNotEmpty;

    final displayItems = showAll
        ? filteredItems
        : filteredItems.where((i) => i.countedQuantity > 0).toList();

    final totalCounted = audit.items.where((i) => i.countedQuantity > 0).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Bar: Audit Info & Actions
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auditoría #${audit.id} - Almacén ${audit.warehouseId}',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Items contados: $totalCounted / ${audit.items.length}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (audit.status.name != 'completed') ...[
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.invalidate(inventoryAuditViewModelProvider),
                  icon: const Icon(Icons.close),
                  label: const Text('Cerrar Vieal'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _confirmCompleteAudit(context, ref),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Finalizar y Ajustar'),
                ),
              ],
            ],
          ),
        ),

        // Tool Bar (Scanning + Search)
        if (audit.status.name != 'completed')
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerLow,
            child: Row(
              children: [
                // Quick Scan
                Expanded(
                  flex: 3,
                  child: InventoryScanWidget(
                    hint: 'Escanear para sumar (+1)',
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
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 24),
                // Search / Filter
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _filterController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o código...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      suffixIcon: _filterText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _filterController.clear();
                                setState(() => _filterText = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _filterText = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

        // Items Table
        Expanded(
          child: displayItems.isEmpty
              ? Center(
                  child: Text(
                    _filterText.isNotEmpty
                        ? 'No se encontraron productos.'
                        : 'No se han contado items aún.\nUse el buscador o escáner para comenzar.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Producto')),
                          DataColumn(label: Text('Código de Barras')),
                          DataColumn(label: Text('Sistema')),
                          DataColumn(label: Text('Físico')),
                          DataColumn(label: Text('Diferencia')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: displayItems.map((item) {
                          final diff = item.difference;
                          final diffColor = diff == 0
                              ? Colors.green
                              : (diff > 0 ? Colors.blue : Colors.red);
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  item.variantName != null
                                      ? '${item.productName} - ${item.variantName}'
                                      : item.productName ?? '-',
                                ),
                              ),
                              DataCell(Text(item.barcode ?? '-')),
                              DataCell(Text('${item.expectedQuantity}')),
                              DataCell(
                                Text(
                                  '${item.countedQuantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  diff > 0 ? '+$diff' : '$diff',
                                  style: TextStyle(
                                    color: diffColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showEditCountDialog(context, ref, item),
                                  tooltip: 'Editar cantidad',
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _showStartAuditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Toma de Inventario'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esto iniciará una nueva sesión de auditoría para el Almacén Principal.',
            ),
            SizedBox(height: 8),
            Text(
              'Nota: Se tomará una "foto" del stock actual del sistema para comparar.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  .startNewAudit(1);
              Navigator.pop(context);
            },
            child: const Text('Iniciar Auditoría'),
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
        title: Text('Editar: ${item.productName ?? 'Desconocido'}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad Física Real'),
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
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _confirmCompleteAudit(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Finalizar Auditoría?'),
        content: const Text(
          'Esta acción actualizará el stock de todos los productos auditados para que coincidan con el conteo físico.\n\nSe generarán movimientos de ajuste por inventario.\n\n¿Está seguro?',
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
            child: const Text('Confirmar y Ajustar Stock'),
          ),
        ],
      ),
    );
  }
}

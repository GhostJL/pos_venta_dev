import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/inventory_audit.dart';
import 'package:posventa/presentation/providers/inventory/inventory_audit_view_model.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_audit_pdf_builder.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/store_provider.dart';
import 'package:posventa/presentation/pages/inventory/widgets/quick_audit_view.dart';

class InventoryAuditDesktopPage extends ConsumerStatefulWidget {
  const InventoryAuditDesktopPage({super.key});

  @override
  ConsumerState<InventoryAuditDesktopPage> createState() =>
      _InventoryAuditDesktopPageState();
}

class _InventoryAuditDesktopPageState
    extends ConsumerState<InventoryAuditDesktopPage> {
  final TextEditingController _smartSearchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _filterText = '';

  @override
  void dispose() {
    _smartSearchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmitted(String value) async {
    if (value.isEmpty) return;
    final audit = ref.read(inventoryAuditViewModelProvider).value;
    if (audit?.status == InventoryAuditStatus.completed) {
      _showErrorSnackBar(
        'La auditoría está finalizada. No se pueden modificar datos.',
      );
      return;
    }
    try {
      await ref
          .read(inventoryAuditViewModelProvider.notifier)
          .scanProduct(value);
      _smartSearchController.clear();
      setState(() {
        _filterText = '';
      });
      _searchFocusNode.requestFocus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto escaneado correctamente (+1)'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('No se pudo agregar: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 350, child: _buildSidebar(context, ref)),
          const VerticalDivider(width: 1),
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
                onPressed: () => ref.invalidate(inventoryAuditListProvider),
                icon: const Icon(Icons.refresh),
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
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final audit = audits[index];
                  final isSelected =
                      ref.watch(inventoryAuditViewModelProvider).value?.id ==
                      audit.id;

                  // Status Text and Color
                  String statusText = 'Desconocido';
                  Color statusColor = Colors.grey;
                  switch (audit.status) {
                    case InventoryAuditStatus.draft:
                      statusText = 'EN PROCESO';
                      statusColor = Colors.orange;
                      break;
                    case InventoryAuditStatus.completed:
                      statusText = 'FINALIZADA';
                      statusColor = Colors.green;
                      break;
                    case InventoryAuditStatus.cancelled:
                      statusText = 'CANCELADA';
                      statusColor = Colors.red;
                      break;
                  }

                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.2),
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
                      DateFormat(
                        'dd MMM yyyy, HH:mm',
                        'es',
                      ).format(audit.auditDate),
                    ),
                    subtitle: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      ref
                          .read(inventoryAuditViewModelProvider.notifier)
                          .loadAudit(audit.id!);
                      _smartSearchController.clear();
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showStartAuditDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nueva Auditoría'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, WidgetRef ref) {
    final activeAuditAsync = ref.watch(inventoryAuditViewModelProvider);
    final quickAuditIndex = ref.watch(quickAuditStateProvider);

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
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Seleccione una auditoría para ver detalles',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }
        if (quickAuditIndex >= 0) {
          return QuickAuditView(audit: audit);
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
    final isLocked = audit.status == InventoryAuditStatus.completed;

    final filteredItems = audit.items.where((item) {
      if (_filterText.isEmpty) return true;
      final term = _filterText.toLowerCase();
      final name = item.productName?.toLowerCase() ?? '';
      final barcode = item.barcode?.toLowerCase() ?? '';
      final variant = item.variantName?.toLowerCase() ?? '';
      return name.contains(term) ||
          barcode.contains(term) ||
          variant.contains(term);
    }).toList();

    final totalCounted = audit.items.where((i) => i.countedQuantity > 0).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
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
                      'Progreso: $totalCounted de ${audit.items.length} productos contados',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLocked) ...[
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.invalidate(inventoryAuditViewModelProvider),
                  icon: const Icon(Icons.close),
                  label: const Text('Cerrar Vista'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => ref
                      .read(inventoryAuditViewModelProvider.notifier)
                      .startQuickAudit(),
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Modo Rápido'),
                ),
                const SizedBox(width: 12),
              ],
              OutlinedButton.icon(
                onPressed: () => _viewReport(audit),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Ver Reporte'),
              ),
            ],
          ),
        ),
        // Search
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _smartSearchController,
            focusNode: _searchFocusNode,
            decoration: const InputDecoration(
              labelText: 'Escanear código de barras o buscar producto',
              prefixIcon: Icon(Icons.qr_code_scanner),
              border: OutlineInputBorder(),
              helperText: 'Presiona Enter para buscar o sumar cantidad (+1)',
            ),
            onChanged: (val) => setState(() => _filterText = val),
            onSubmitted: _handleSubmitted,
            textInputAction: TextInputAction.go,
          ),
        ),
        // Table
        Expanded(
          child: filteredItems.isEmpty
              ? const Center(
                  child: Text('No hay productos que coincidan con la búsqueda'),
                )
              : SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Producto')),
                      DataColumn(label: Text('Código')),
                      DataColumn(
                        label: Text('Esperado', textAlign: TextAlign.right),
                      ),
                      DataColumn(
                        label: Text('Físico', textAlign: TextAlign.right),
                      ),
                      DataColumn(
                        label: Text('Diferencia', textAlign: TextAlign.right),
                      ),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: filteredItems.map((item) {
                      final diff = item.difference;
                      final diffColor = diff == 0
                          ? Colors.green
                          : (diff > 0 ? Colors.blue : Colors.red);
                      final name = item.variantName != null
                          ? '${item.productName} - ${item.variantName}'
                          : item.productName ?? '-';

                      return DataRow(
                        cells: [
                          DataCell(Text(name)),
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
                            isLocked
                                ? const SizedBox()
                                : IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _showEditCountDialog(context, item),
                                    tooltip: 'Editar cantidad manual',
                                  ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
        // Footer Actions
        if (!isLocked)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _confirmFillStock(context),
                  child: const Text('Copiar Stock Sistema'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => _confirmCompleteAudit(context),
                  child: const Text('Finalizar Auditoría'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showStartAuditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Auditoría'),
        content: const Text(
          '¿Iniciar nueva auditoría en Almacén Principal?\nSe cargará el inventario actual del sistema.',
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
    InventoryAuditItemEntity item,
  ) {
    final controller = TextEditingController(
      text: item.countedQuantity.toString().replaceAll('.0', ''),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar: ${item.productName}'),
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
              final val = double.tryParse(controller.text) ?? 0;
              ref
                  .read(inventoryAuditViewModelProvider.notifier)
                  .updateItemCount(item.id!, val);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmFillStock(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Copiar Stock del Sistema?'),
        content: const Text(
          'Esta acción establecerá la cantidad contada igual a la esperada para TODOS los productos.\n\nÚselo con precaución.',
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
            child: const Text('Confirmar Copia'),
          ),
        ],
      ),
    );
  }

  void _confirmCompleteAudit(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Auditoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta acción actualizará el inventario PERMANENTEMENTE.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Observaciones / Motivo',
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
              final completed = await ref
                  .read(inventoryAuditViewModelProvider.notifier)
                  .completeAudit(reason: reasonController.text);
              if (completed != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Auditoría Finalizada.'),
                    backgroundColor: Colors.green,
                  ),
                );
                _viewReport(completed);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _viewReport(InventoryAuditEntity audit) async {
    final user = ref.read(authProvider).user;
    final store = await ref.read(storeProvider.future);
    await InventoryAuditPdfBuilder.generateAndOpen(
      audit: audit,
      store: store,
      warehouseName: 'Almacén Principal',
      userName: user?.name ?? 'Usuario',
      title: 'Reporte de Auditoría',
    );
  }
}

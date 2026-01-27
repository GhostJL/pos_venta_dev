import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/inventory_audit.dart';
import 'package:posventa/presentation/providers/inventory/inventory_audit_view_model.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_audit_pdf_builder.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
// Removed InventoryScanWidget import as we are implementing unified logic here

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

  /// Handles "Smart" logic:
  /// - If Enter is pressed: Try to Scan (Increment Count)
  /// - As user types: Filter the list (handled by onChanged -> setState)
  void _handleSubmitted(String value) async {
    if (value.isEmpty) return;

    // Logic: "Scan" implies incrementing count.
    // If the audit is completed, we shouldn't allow scanning.
    final audit = ref.read(inventoryAuditViewModelProvider).value;
    if (audit?.status == InventoryAuditStatus.completed) {
      _showErrorSnackBar(
        'La auditoría está finalizada. No se pueden modificar datos.',
      );
      return;
    }

    // Try to scan/increment
    try {
      await ref
          .read(inventoryAuditViewModelProvider.notifier)
          .scanProduct(value);

      // If successful, clear to be ready for next scan
      _smartSearchController.clear();
      setState(() {
        _filterText = '';
      });
      // Keep focus for continuous scanning
      _searchFocusNode.requestFocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto escaneado: $value (+1)'),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      // If scan fails (product not found in this audit LIST),
      // check if it is at least a valid search term.
      // If the user just wanted to SEARCH and hit enter, we don't want to error if it's just a name.
      // But typically "Enter" in a POS context with a barcode means "Action".
      // Let's assume Scan first. If error, show error but keep text for filtering.
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
                tooltip: 'Actualizar lista',
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

                  // Localization map for status
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
                        .withValues(alpha: 0.2), // Fixed withOpacity
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
                      // Focus search when loading an audit
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (_searchFocusNode.canRequestFocus) {
                          _searchFocusNode.requestFocus();
                        }
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
              label: const Text('Nueva Auditoría'),
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
                  color: Theme.of(context).colorScheme.outline.withValues(
                    alpha: 0.5,
                  ), // Fixed withOpacity
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
                OutlinedButton.icon(
                  onPressed: () => _viewReport(audit),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Ver Reporte'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _confirmFillStock(context, ref),
                  icon: const Icon(Icons.copy_all),
                  label: const Text('Copiar Stock Sistema'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _confirmCompleteAudit(context, ref),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Finalizar Auditoría'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(
                      alpha: 0.1,
                    ), // Fixed withOpacity
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, size: 16, color: Colors.green[800]),
                      const SizedBox(width: 8),
                      Text(
                        'Auditoría Finalizada',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(inventoryAuditViewModelProvider),
                  child: const Text('Cerrar'),
                ),
              ],
            ],
          ),
        ),

        // Unified Smart Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainerLow,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _smartSearchController,
                  focusNode: _searchFocusNode,
                  enabled: !isLocked,
                  // We allow typing to search history even if locked
                  // But Logic in onSubmitted handles the lock check for scanning
                  decoration: InputDecoration(
                    hintText: isLocked
                        ? 'Buscar en historial...'
                        : 'Buscar producto o Escanear código de barras...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _filterText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _smartSearchController.clear();
                              setState(() => _filterText = '');
                              _searchFocusNode.requestFocus();
                            },
                          )
                        : const Icon(Icons.qr_code_scanner, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _filterText = val;
                    });
                  },
                  onSubmitted: (val) {
                    // Only allow scanning new items if not locked
                    if (!isLocked) {
                      _handleSubmitted(val);
                    }
                  },
                  textInputAction: TextInputAction.send,
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
                        ? 'No se encontraron productos con ese criterio.'
                        : (isLocked
                              ? 'No se encontraron registros.'
                              : 'Escanee un código o busque un producto para comenzar.'),
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
                          DataColumn(label: Text('Producto / Variante')),
                          DataColumn(label: Text('Código')),
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
                                isLocked
                                    ? const Icon(
                                        Icons.lock_outline,
                                        size: 16,
                                        color: Colors.grey,
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _showEditCountDialog(
                                          context,
                                          ref,
                                          item,
                                        ),
                                        tooltip: 'Editar cantidad manual',
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
        title: const Text('Nueva Auditoría'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Esto iniciará una nueva sesión de auditoría.'),
            SizedBox(height: 8),
            Text(
              'Nota: Se guardará una copia del stock actual del sistema para calcular diferencias.',
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
        title: const Text('¿Finalizar Auditoría?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta acción actualizará el stock de todos los productos y cerrará la auditoría de forma permanente.\n\nNo se podrán realizar más cambios.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo / Comentarios (Opcional)',
                hintText: 'Ej: Diferencias por merma, Ajuste anual...',
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
              Navigator.pop(context); // Close dialog first

              final completedAudit = await ref
                  .read(inventoryAuditViewModelProvider.notifier)
                  .completeAudit(reason: reasonController.text);

              if (completedAudit != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Auditoría finalizada correctamente. Generando reporte...',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                // Generate and Open PDF
                final user = ref.read(authProvider).user;
                final userName =
                    user?.name ?? 'Usuario #${ref.read(authProvider).user?.id}';

                await InventoryAuditPdfBuilder.generateAndOpen(
                  audit: completedAudit,
                  warehouseName:
                      'Almacén Principal', // Ideally fetch from a warehouse provider or active selection
                  userName: userName,
                  title: 'Reporte Final de Auditoría',
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green[700]),
            child: const Text('Confirmar Finalización'),
          ),
        ],
      ),
    );
  }

  // Helper to view report for current audit (Preliminary or Final)
  void _viewReport(InventoryAuditEntity audit) async {
    final user = ref.read(authProvider).user;
    final userName = user?.name ?? 'Usuario #${user?.id}';

    await InventoryAuditPdfBuilder.generateAndOpen(
      audit: audit,
      warehouseName:
          'Almacén Principal', // Placeholder until warehouse name is available in entity/provider
      userName: userName,
      title: audit.status == InventoryAuditStatus.completed
          ? 'Reporte Final de Auditoría'
          : 'Reporte Preliminar de Auditoría',
    );
  }

  void _confirmFillStock(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Copiar Stock del Sistema?'),
        content: const Text(
          'Esto sobrescribirá todos los conteos físicos actuales con la cantidad que el sistema esperaba al inicio de la auditoría.\n\nÚtil si el inventario físico coincide mayormente con el sistema y solo desea ajustar diferencias.',
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
            child: const Text('Copiar Stock'),
          ),
        ],
      ),
    );
  }
}

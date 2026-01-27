import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/inventory_audit.dart';
import 'package:posventa/presentation/providers/inventory/inventory_audit_view_model.dart';
import 'package:posventa/presentation/widgets/common/misc/barcode_scanner_widget.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_audit_pdf_builder.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/store_provider.dart';
import 'package:posventa/presentation/widgets/menu/side_menu.dart';
import 'package:posventa/presentation/pages/inventory/widgets/quick_audit_view.dart';

class InventoryAuditMobilePage extends ConsumerStatefulWidget {
  const InventoryAuditMobilePage({super.key});

  @override
  ConsumerState<InventoryAuditMobilePage> createState() =>
      _InventoryAuditMobilePageState();
}

class _InventoryAuditMobilePageState
    extends ConsumerState<InventoryAuditMobilePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _filterText = '';
  // Used to debounce searches if needed, or just standard state update

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    setState(() {
      _filterText = value;
    });
  }

  Future<void> _handleScan(String code) async {
    if (code.isEmpty) return;
    try {
      await ref
          .read(inventoryAuditViewModelProvider.notifier)
          .scanProduct(code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto escaneado: $code (+1)'),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 800),
        ),
      );
      _searchController.clear();
      setState(() {
        _filterText = '';
      });
      _searchFocusNode.requestFocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _openCameraScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWidget(
          onBarcodeScanned: (context, code) {
            Navigator.pop(context);
            _handleScan(code);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeAuditAsync = ref.watch(inventoryAuditViewModelProvider);
    final quickAuditIndex = ref.watch(quickAuditStateProvider);

    return Scaffold(
      drawer: const SideMenu(), // Assuming SideMenu exists
      appBar: activeAuditAsync.value == null
          ? AppBar(title: const Text('Auditoría de Inventario'))
          : null, // If active, we usually show custom appbar within the view or here.
      // Let's keep the main appbar for lists.
      body: activeAuditAsync.when(
        data: (audit) {
          if (audit == null) {
            return _buildAuditHistoryList(context);
          }

          // If Quick Audit Mode is active, show that view
          if (quickAuditIndex >= 0) {
            return QuickAuditView(audit: audit);
          }

          return _buildActiveAuditView(context, audit);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildAuditHistoryList(BuildContext context) {
    // This should list previous audits and allow creating a new one
    final auditList = ref.watch(inventoryAuditListProvider);

    return auditList.when(
      data: (audits) {
        return Column(
          children: [
            Expanded(
              child: audits.isEmpty
                  ? const Center(child: Text('No hay auditorías registradas.'))
                  : ListView.builder(
                      itemCount: audits.length,
                      itemBuilder: (context, index) {
                        final audit = audits[index];
                        return ListTile(
                          title: Text('Auditoría #${audit.id}'),
                          subtitle: Text(
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(audit.auditDate),
                          ),
                          trailing: _buildStatusChip(context, audit.status),
                          onTap: () {
                            ref
                                .read(inventoryAuditViewModelProvider.notifier)
                                .loadAudit(audit.id!);
                          },
                        );
                      },
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error al cargar historial: $e')),
    );
  }

  Widget _buildStatusChip(BuildContext context, InventoryAuditStatus status) {
    Color color;
    String label;
    switch (status) {
      case InventoryAuditStatus.draft:
        color = Colors.orange;
        label = 'En Proceso';
        break;
      case InventoryAuditStatus.completed:
        color = Colors.green;
        label = 'Finalizada';
        break;
      case InventoryAuditStatus.cancelled:
        color = Colors.red;
        label = 'Cancelada';
        break;
    }
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildActiveAuditView(
    BuildContext context,
    InventoryAuditEntity audit,
  ) {
    final theme = Theme.of(context);
    final isLocked = audit.status == InventoryAuditStatus.completed;

    final filteredItems = audit.items.where((item) {
      if (_filterText.isEmpty) return true;
      final term = _filterText.toLowerCase();
      final name = item.productName?.toLowerCase() ?? '';
      final barcode = item.barcode?.toLowerCase() ?? '';
      return name.contains(term) || barcode.contains(term);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Auditoría #${audit.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.invalidate(inventoryAuditViewModelProvider),
        ),
        actions: [
          if (!isLocked)
            IconButton(
              icon: const Icon(Icons.flash_on),
              tooltip: 'Modo Rápido',
              onPressed: () {
                ref
                    .read(inventoryAuditViewModelProvider.notifier)
                    .startQuickAudit();
              },
            ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _viewReport(context, audit),
          ),
          if (!isLocked)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'fill',
                  child: Text('Copiar Stock Sistema'),
                ),
                const PopupMenuItem(
                  value: 'finish',
                  child: Text('Finalizar Auditoría'),
                ),
              ],
              onSelected: (value) {
                if (value == 'fill') _confirmFillStock(context);
                if (value == 'finish') _confirmCompleteAudit(context);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Scan Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Buscar o Escanear...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _filterText = '');
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _handleSearch,
                    onSubmitted: _handleScan,
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _openCameraScanner,
                  icon: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return _buildAuditItemCard(
                  context,
                  filteredItems[index],
                  isLocked,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditItemCard(
    BuildContext context,
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        onTap: isLocked ? null : () => _showEditCountDialog(context, item),
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

  void _showStartAuditDialog(BuildContext context) {
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

  void _confirmFillStock(BuildContext context) {
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

  void _confirmCompleteAudit(BuildContext context) {
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
                _viewReport(context, completedAudit);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _viewReport(BuildContext context, InventoryAuditEntity audit) async {
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

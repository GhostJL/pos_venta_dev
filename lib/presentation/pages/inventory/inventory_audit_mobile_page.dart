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

      if (!mounted) return;

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
      if (!mounted) return;
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
    final auditList = ref.watch(inventoryAuditListProvider);
    final theme = Theme.of(context);

    return auditList.when(
      data: (audits) {
        return Column(
          children: [
            Expanded(
              child: audits.isEmpty
                  ? const Center(child: Text('No hay auditorías registradas.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: audits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final audit = audits[index];
                        // Status Config
                        Color statusColor;
                        Color statusBg;
                        String statusText;
                        switch (audit.status) {
                          case InventoryAuditStatus.draft:
                            statusColor = const Color(0xFFD97706); // Amber 700
                            statusBg = const Color(0xFFFEF3C7); // Amber 100
                            statusText = 'En Proceso';
                            break;
                          case InventoryAuditStatus.completed:
                            statusColor = const Color(0xFF15803D); // Green 700
                            statusBg = const Color(0xFFDCFCE7); // Green 100
                            statusText = 'Finalizada';
                            break;
                          case InventoryAuditStatus.cancelled:
                            statusColor = const Color(0xFFB91C1C); // Red 700
                            statusBg = const Color(0xFFFEE2E2); // Red 100
                            statusText = 'Cancelada';
                            break;
                        }

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              ref
                                  .read(
                                    inventoryAuditViewModelProvider.notifier,
                                  )
                                  .loadAudit(audit.id!);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.assignment_turned_in_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Auditoría #${audit.id}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat(
                                            'dd MMM yyyy, HH:mm',
                                            'es',
                                          ).format(audit.auditDate),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showStartAuditDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Nueva Auditoría',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
              ],
              onSelected: (value) {
                if (value == 'fill') _confirmFillStock(context);
              },
            ),
        ],
      ),
      floatingActionButton: !isLocked
          ? FloatingActionButton.extended(
              onPressed: () => _confirmCompleteAudit(context),
              icon: const Icon(Icons.check),
              label: const Text('Finalizar'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            )
          : null,
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

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLocked ? null : () => _showEditCountDialog(context, item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Part
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A), // Dark Navy
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text Part
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.productName ?? 'Desconocido',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Status Badge (like 'En Stock' but for audit status)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: hasCount
                                    ? (isMatch
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(
                                              0xFFDBEAFE,
                                            )) // Green or Blue bg
                                    : const Color(0xFFF1F5F9), // Slate 100
                                borderRadius: BorderRadius.circular(6),
                                border: hasCount
                                    ? Border.all(
                                        color: isMatch
                                            ? const Color(0xFF22C55E)
                                            : const Color(0xFF3B82F6),
                                      )
                                    : null,
                              ),
                              child: Text(
                                hasCount
                                    ? (isMatch
                                          ? 'Cuadrado'
                                          : (diff > 0
                                                ? 'Excedente'
                                                : 'Faltante'))
                                    : 'Pendiente',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: hasCount
                                      ? (isMatch
                                            ? const Color(0xFF15803D)
                                            : const Color(0xFF1D4ED8))
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (item.variantName != null)
                          Text(
                            item.variantName!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ), // Slate 500
                          ),
                        const SizedBox(height: 2),
                        Text(
                          'SKU: ${item.barcode ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ), // Slate 400
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),

              // Bottom Metrics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildListMetric('Sistema', '${item.expectedQuantity}'),
                  // If counted, show physical, else show ---
                  _buildListMetric(
                    'Físico',
                    hasCount ? '${item.countedQuantity}' : '-',
                    isBold: true,
                  ),

                  // Diff
                  if (hasCount)
                    _buildListMetric(
                      'Diferencia',
                      (diff > 0 ? '+$diff' : '$diff'),
                      color: diff == 0
                          ? Colors.green
                          : (diff > 0 ? Colors.blue : Colors.red),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListMetric(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ), // Slate 500
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold || color != null
                ? FontWeight.bold
                : FontWeight.normal,
            color: color ?? const Color(0xFF0F172A),
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

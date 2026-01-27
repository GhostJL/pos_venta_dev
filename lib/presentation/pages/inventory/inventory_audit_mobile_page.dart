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

class InventoryAuditMobilePage extends ConsumerStatefulWidget {
  const InventoryAuditMobilePage({super.key});

  @override
  ConsumerState<InventoryAuditMobilePage> createState() =>
      _InventoryAuditMobilePageState();
}

class _InventoryAuditMobilePageState
    extends ConsumerState<InventoryAuditMobilePage> {
  final TextEditingController _searchController = TextEditingController();
  String _filterText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    setState(() {
      _filterText = value.toLowerCase();
    });
  }

  Future<void> _handleScan(String code) async {
    if (code.isEmpty) return;

    // Check if it's a known product in the audit
    final audit = ref.read(inventoryAuditViewModelProvider).asData?.value;
    if (audit == null) return;

    final isKnown = audit.items.any((item) => item.barcode == code);

    if (isKnown) {
      try {
        await ref
            .read(inventoryAuditViewModelProvider.notifier)
            .scanProduct(code);
        _searchController.clear();
        setState(() => _filterText = '');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto Agregado (+1)'),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 600),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // If simply filtering, do nothing special on enter except maybe show "not found"
      // But since we filter on change, enter usually means "I want to scan this"
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto no encontrado en la auditoría'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _openCameraScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWidget(
          onBarcodeScanned: (context, code) {
            Navigator.of(context).pop(); // Close scanner
            _handleScan(code);
          },
          title: 'Escanear Producto',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeAuditAsync = ref.watch(inventoryAuditViewModelProvider);

    return activeAuditAsync.when(
      data: (audit) {
        if (audit == null) {
          return _buildAuditHistoryList(context);
        }
        return _buildActiveAuditView(context, audit);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildAuditHistoryList(BuildContext context) {
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
        onPressed: () => _showStartAuditDialog(context),
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
              return _buildAuditHistoryCard(context, audit);
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
    InventoryAuditEntity audit,
  ) {
    final theme = Theme.of(context);
    final isLocked = audit.status == InventoryAuditStatus.completed;

    // Filter Items
    final filteredItems = audit.items.where((item) {
      if (_filterText.isEmpty) return true;
      final name = item.productName?.toLowerCase() ?? '';
      final code = item.barcode?.toLowerCase() ?? '';
      return name.contains(_filterText) || code.contains(_filterText);
    }).toList();

    // Sort: Counted first
    filteredItems.sort((a, b) {
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
          if (!isLocked)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Finalizar',
              onPressed: () => _confirmCompleteAudit(context),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') _viewReport(context, audit);
              if (value == 'copy') _confirmFillStock(context);
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

          // Unified Smart Input (Search + Scan)
          if (!isLocked)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _handleSearch,
                onSubmitted: _handleScan,
                textInputAction: TextInputAction.send, // "Enter" to scan
                decoration: InputDecoration(
                  hintText: 'Buscar o Escanear producto...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _handleSearch('');
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        tooltip: 'Usar Cámara',
                        onPressed: _openCameraScanner,
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),

          // Items List
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      _filterText.isEmpty
                          ? 'No hay items'
                          : 'No se encontraron productos',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildAuditItemCard(context, item, isLocked);
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/inventory_providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';
import 'package:posventa/presentation/viewmodels/inventory_view_model.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_card_widget.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_header.dart';
import 'package:posventa/presentation/widgets/inventory/inventory_table_row.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Correctly handle AsyncValue reading
    final settingsAsync = ref.watch(settingsProvider);
    final useInventory = settingsAsync.asData?.value.useInventory ?? false;
    final theme = Theme.of(context);

    if (settingsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!useInventory) {
      return Scaffold(
        body: Center(
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
                'Gestión de Inventario Desactivada',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Activa el control de inventario en Configuración > Sistema para usar esta función.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final inventoryState = ref.watch(inventoryViewModelProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, isDesktop),

              if (inventoryState.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (inventoryState.error != null)
                SliverFillRemaining(
                  child: Center(child: Text('Error: ${inventoryState.error}')),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: _SummarySection(stats: inventoryState.stats),
                  ),
                ),

                // Search & Filter
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    minHeight: 80,
                    maxHeight: 80,
                    child: Container(
                      color: theme.colorScheme.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: SearchBar(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor: WidgetStateProperty.all(
                          theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        hintText: 'Buscar por nombre, SKU o código...',
                        leading: const Icon(Icons.search),
                        onChanged: (val) {
                          ref
                              .read(inventorySearchQueryProvider.notifier)
                              .update(val);
                        },
                        trailing: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(inventorySearchQueryProvider.notifier)
                                    .update('');
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (inventoryState.items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron resultados',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Content Layout
                  isDesktop
                      ? _buildDesktopTable(inventoryState.items)
                      : _buildMobileList(inventoryState.items),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Provide manual refresh action
          ref.invalidate(inventoryProvider);
          ref.invalidate(productNotifierProvider);
          ref.invalidate(warehousesProvider);
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Actualizar'),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return const SliverAppBar(
      title: Text('Inventario'),
      floating: true,
      snap: true,
    );
  }

  Widget _buildDesktopTable(List<InventoryDisplayItem> items) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) return const InventoryHeader();
        final item = items[index - 1];
        return InventoryTableRow(
          inventory: item.inventory,
          product: item.product,
          variant: item.variant,
          warehouse: item.warehouse,
        );
      }, childCount: items.length + 1),
    );
  }

  Widget _buildMobileList(List<InventoryDisplayItem> items) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = items[index];
        return InventoryCardWidget(
          inventory: item.inventory,
          product: item.product,
          variant: item.variant,
          warehouse: item.warehouse,
        );
      }, childCount: items.length),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final InventoryStats stats;
  const _SummarySection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'VALORACIÓN',
            value: '\$${(stats.totalValue).toStringAsFixed(2)}',
            subValue: '${stats.totalItems} productos',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            label: 'BAJO STOCK',
            value: stats.lowStockCount.toString(),
            subValue: 'Requieren atención',
            icon: Icons.warning_amber_rounded,
            color: stats.lowStockCount > 0
                ? Colors.orange
                : theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.subValue,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subValue,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _StickyHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

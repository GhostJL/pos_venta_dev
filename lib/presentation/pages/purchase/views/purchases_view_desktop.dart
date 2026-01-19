import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/providers/paginated_purchases_provider.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';
import 'package:posventa/presentation/widgets/purchases/dialogs/purchase_cancel_dialog.dart';
import 'package:go_router/go_router.dart';

class PurchasesViewDesktop extends ConsumerWidget {
  final int totalCount;
  final ScrollController scrollController;
  final Function() onRefresh;

  const PurchasesViewDesktop({
    super.key,
    required this.totalCount,
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Desktop: Use a Table or DataTable-like structure for density
    // For large lists, we'll keep the custom ListView builder but style it as a table rows
    return Column(
      children: [
        _buildTableHeader(context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: ListView.builder(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: totalCount,
              itemBuilder: (context, index) {
                final pageIndex = index ~/ kPurchasePageSize;
                final indexInPage = index % kPurchasePageSize;
                final pageAsync = ref.watch(
                  paginatedPurchasesPageProvider(pageIndex: pageIndex),
                );

                return pageAsync.when(
                  data: (purchases) {
                    if (indexInPage >= purchases.length) {
                      return const SizedBox.shrink();
                    }
                    final purchase = purchases[indexInPage];
                    return _PurchaseDesktopRow(purchase: purchase);
                  },
                  loading: () => const LinearProgressIndicator(minHeight: 1),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          _HeaderCell('Folio', flex: 2),
          _HeaderCell('Proveedor', flex: 4),
          _HeaderCell('Fecha', flex: 2),
          _HeaderCell('Almacén', flex: 2),
          _HeaderCell('Total', flex: 2, alignRight: true),
          _HeaderCell('Estado', flex: 2, center: true),
          _HeaderCell('', flex: 1, center: true),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool alignRight;
  final bool center;

  const _HeaderCell(
    this.text, {
    required this.flex,
    this.alignRight = false,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        textAlign: center
            ? TextAlign.center
            : (alignRight ? TextAlign.right : TextAlign.left),
      ),
    );
  }
}

class _PurchaseDesktopRow extends ConsumerStatefulWidget {
  final Purchase purchase;

  const _PurchaseDesktopRow({required this.purchase});

  @override
  ConsumerState<_PurchaseDesktopRow> createState() =>
      _PurchaseDesktopRowState();
}

class _PurchaseDesktopRowState extends ConsumerState<_PurchaseDesktopRow> {
  bool _isHovering = false;
  final GlobalKey _menuKey = GlobalKey();

  Future<void> _handleMenuAction(String value) async {
    final purchase = widget.purchase;
    switch (value) {
      case 'view':
        context.push('/purchases/${purchase.id}');
        break;
      case 'receive':
        context.push('/purchases/reception/${purchase.id}');
        break;
      case 'cancel':
        final confirmed = await PurchaseCancelDialog.show(
          context: context,
          purchase: purchase,
        );

        if (confirmed == true && mounted) {
          try {
            final user = ref.read(authProvider).user;
            if (user == null) return;

            await ref
                .read(purchaseProvider.notifier)
                .cancelPurchase(purchase.id!, user.id!);

            ref.invalidate(paginatedPurchasesCountProvider);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        }
        break;
    }
  }

  void _showContextMenu(Offset position) {
    final purchase = widget.purchase;
    final theme = Theme.of(context);
    final isPending = purchase.status == PurchaseStatus.pending;
    final isPartial = purchase.status == PurchaseStatus.partial;

    final items = [
      const PopupMenuItem(
        value: 'view',
        child: Row(
          children: [
            Icon(Icons.visibility_outlined, size: 20),
            SizedBox(width: 12),
            Text('Ver Detalle'),
          ],
        ),
      ),
      if (isPending || isPartial)
        PopupMenuItem(
          value: 'receive',
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20,
                color: context.paymentSuccess,
              ),
              const SizedBox(width: 12),
              const Text('Recibir Compra'),
            ],
          ),
        ),
      if (isPending)
        PopupMenuItem(
          value: 'cancel',
          child: Row(
            children: [
              Icon(
                Icons.cancel_outlined,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 12),
              const Text('Cancelar Compra'),
            ],
          ),
        ),
    ];

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: items,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).then((value) {
      if (value != null) {
        _handleMenuAction(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final purchase = widget.purchase;
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Status colors
    Color statusColor;
    String statusText;
    switch (purchase.status) {
      case PurchaseStatus.completed:
        statusColor = context.paymentSuccess;
        statusText = 'Completado';
        break;
      case PurchaseStatus.pending:
      case PurchaseStatus.partial:
        statusColor = context.paymentPending;
        statusText = 'Pendiente';
        break;
      case PurchaseStatus.cancelled:
        statusColor = context.paymentFailed;
        statusText = 'Cancelado';
        break;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onSecondaryTapUp: (details) {
          _showContextMenu(details.globalPosition);
        },
        child: InkWell(
          onTap: () {
            context.push('/purchases/${purchase.id}');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
              color: _isHovering
                  ? theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    )
                  : theme.colorScheme.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '#${purchase.purchaseNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    purchase.supplierName ?? 'Sin Proveedor',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    dateFormat.format(purchase.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    purchase.warehouseName ?? 'General',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    currency.format(purchase.total),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: _isHovering
                          ? IconButton(
                              key: _menuKey,
                              icon: const Icon(Icons.more_vert),
                              tooltip: 'Acciones',
                              onPressed: () {
                                final renderBox =
                                    _menuKey.currentContext!.findRenderObject()
                                        as RenderBox;
                                final position = renderBox.localToGlobal(
                                  Offset.zero,
                                );
                                _showContextMenu(
                                  position + Offset(0, renderBox.size.height),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

class PurchasesViewMobile extends ConsumerWidget {
  final int totalCount;
  final ScrollController scrollController;
  final Function() onRefresh;

  const PurchasesViewMobile({
    super.key,
    required this.totalCount,
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: totalCount,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
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
              return _PurchaseMobileCard(purchase: purchase);
            },
            loading: () => const _SkeletonCard(),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _PurchaseMobileCard extends ConsumerWidget {
  final Purchase purchase;

  const _PurchaseMobileCard({required this.purchase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Card(
      child: InkWell(
        onTap: () {
          context.push('/purchases/${purchase.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${purchase.purchaseNumber}',
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
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      purchase.supplierName ?? 'Proveedor Desconocido',
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(purchase.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ITEMS', style: theme.textTheme.labelSmall),
                      Text(
                        '${purchase.items.length}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('TOTAL', style: theme.textTheme.labelSmall),
                      Text(
                        currency.format(purchase.total),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: context.paymentSuccess,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (purchase.status == PurchaseStatus.pending ||
                      purchase.status == PurchaseStatus.partial)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextButton.icon(
                        onPressed: () {
                          context.push('/purchases/reception/${purchase.id}');
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Recibir'),
                        style: TextButton.styleFrom(
                          foregroundColor: context.paymentSuccess,
                        ),
                      ),
                    ),
                  if (purchase.status == PurchaseStatus.pending)
                    TextButton.icon(
                      onPressed: () async {
                        final confirmed = await PurchaseCancelDialog.show(
                          context: context,
                          purchase: purchase,
                        );

                        if (confirmed == true) {
                          try {
                            final user = ref.read(authProvider).user;
                            if (user == null) return;

                            await ref
                                .read(purchaseProvider.notifier)
                                .cancelPurchase(purchase.id!, user.id!);

                            ref.invalidate(paginatedPurchasesCountProvider);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancelar'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
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
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

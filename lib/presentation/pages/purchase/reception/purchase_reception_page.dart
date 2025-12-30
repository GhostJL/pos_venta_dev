import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/domain/entities/purchase_reception_item.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/widgets/purchases/reception/reception_item_card.dart';
import 'package:posventa/presentation/widgets/purchases/reception/reception_summary_card.dart';

class PurchaseReceptionPage extends ConsumerStatefulWidget {
  final int purchaseId;

  const PurchaseReceptionPage({super.key, required this.purchaseId});

  @override
  ConsumerState<PurchaseReceptionPage> createState() =>
      _PurchaseReceptionPageState();
}

class _ReceptionItemState {
  final TextEditingController quantityController;
  final TextEditingController lotController;
  final TextEditingController expirationController;
  double quantity;
  DateTime? expirationDate;

  _ReceptionItemState({required double initialQuantity})
    : quantityController = TextEditingController(
        text: initialQuantity.toStringAsFixed(initialQuantity % 1 == 0 ? 0 : 2),
      ),
      lotController = TextEditingController(),
      expirationController = TextEditingController(),
      quantity = initialQuantity;

  void dispose() {
    quantityController.dispose();
    lotController.dispose();
    expirationController.dispose();
  }
}

class _PurchaseReceptionPageState extends ConsumerState<PurchaseReceptionPage> {
  final Map<int, _ReceptionItemState> _itemStates = {};
  bool _isInitialized = false;

  @override
  void dispose() {
    for (final state in _itemStates.values) {
      state.dispose();
    }
    super.dispose();
  }

  void _initializeStates(Purchase purchase) {
    if (_isInitialized) return;
    for (final item in purchase.items) {
      final remaining = item.quantity - item.quantityReceived;
      final id = item.id;
      if (id != null && remaining > 0) {
        _itemStates[id] = _ReceptionItemState(initialQuantity: remaining);
      }
    }
    _isInitialized = true;
  }

  void _receiveAll(Purchase purchase) {
    setState(() {
      for (final item in purchase.items) {
        final remaining = item.quantity - item.quantityReceived;
        final id = item.id;
        if (id != null && remaining > 0) {
          final state = _itemStates[id];
          if (state != null) {
            state.quantity = remaining;
            state.quantityController.text = _formatNumber(remaining);
          }
        }
      }
    });
  }

  void _clearAll() {
    setState(() {
      for (final state in _itemStates.values) {
        state.quantity = 0;
        state.quantityController.text = '0';
      }
    });
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
  }

  Future<void> _selectDate(
    BuildContext context,
    _ReceptionItemState state,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && picked != state.expirationDate) {
      setState(() {
        state.expirationDate = picked;
        state.expirationController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked);
      });
    }
  }

  Future<void> _confirmReception(Purchase purchase) async {
    // 1. Collect items to receive
    final List<PurchaseReceptionItem> itemsToReceive = [];
    _itemStates.forEach((itemId, state) {
      if (state.quantity > 0) {
        String lot = state.lotController.text.trim();
        if (lot.isEmpty) {
          final now = DateTime.now();
          final dateStr = now
              .toIso8601String()
              .substring(0, 10)
              .replaceAll('-', '');
          final timeStr = now
              .toIso8601String()
              .substring(11, 19)
              .replaceAll(':', '');
          lot = 'LOT-$dateStr-$timeStr';
        }

        itemsToReceive.add(
          PurchaseReceptionItem(
            itemId: itemId,
            quantity: state.quantity,
            lotNumber: lot,
            expirationDate: state.expirationDate,
          ),
        );
      }
    });

    if (itemsToReceive.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay items para recibir'),
          backgroundColor: AppTheme.alertWarning,
        ),
      );
      return;
    }

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await ref
          .read(purchaseProvider.notifier)
          .receivePurchase(purchase.id!, itemsToReceive, user.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recepción registrada exitosamente'),
            backgroundColor: AppTheme.transactionSuccess,
          ),
        );
        context.pop(); // Go back to detail
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseAsync = ref.watch(purchaseByIdProvider(widget.purchaseId));
    final productsAsync = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recibir Mercancía')),
      body: purchaseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (purchase) {
          if (purchase == null) {
            return const Center(child: Text('Compra no encontrada'));
          }

          _initializeStates(purchase);

          double totalOrdered = 0;
          double totalReceived = 0;
          double totalPending = 0;

          for (final item in purchase.items) {
            totalOrdered += item.quantity;
            totalReceived += item.quantityReceived;
            final remaining = item.quantity - item.quantityReceived;
            if (remaining > 0) {
              totalPending += _itemStates[item.id]?.quantity ?? 0;
            }
          }

          return Column(
            children: [
              // Items List + Header
              Expanded(
                child: productsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (state) {
                    final products = state.products;
                    final productMap = {for (var p in products) p.id!: p};

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // Scrollable Header
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          child: Column(
                            key: const ValueKey('reception_header'),
                            children: [
                              ReceptionSummaryCard(
                                totalOrdered: totalOrdered,
                                totalReceived: totalReceived,
                                totalPending: totalPending,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: _clearAll,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reiniciar'),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton.tonalIcon(
                                    onPressed: () => _receiveAll(purchase),
                                    icon: const Icon(Icons.done_all),
                                    label: const Text('Recibir Todo'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Actual Items
                        ...purchase.items.map((item) {
                          final remaining =
                              item.quantity - item.quantityReceived;
                          final id = item.id;
                          final product = productMap[item.productId];
                          final variant = product?.variants
                              ?.where((v) => v.id == item.variantId)
                              .firstOrNull;

                          if (remaining <= 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CompletedItemCard(item: item),
                            );
                          }

                          final state = _itemStates[id];
                          if (state == null) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ReceptionItemCard(
                              item: item,
                              product: product,
                              variant: variant,
                              quantityController: state.quantityController,
                              lotController: state.lotController,
                              expirationController: state.expirationController,
                              onQuantityChanged: (qty) {
                                setState(() {
                                  if (qty >= 0 && qty <= remaining) {
                                    state.quantity = qty;
                                  }
                                });
                              },
                              onExpirationTap: () =>
                                  _selectDate(context, state),
                            ),
                          );
                        }),

                        // Extra space for bottom bar
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),

              // Bottom confirm bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancelar Recepción'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: totalPending > 0
                              ? () => _confirmReception(purchase)
                              : null,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Confirmar Recepción'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompletedItemCard extends StatelessWidget {
  final PurchaseItem item;
  const _CompletedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          Icons.check_circle,
          color: AppTheme.transactionSuccess,
          size: 24,
        ),
        title: Text(
          item.productName ?? 'Producto',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Totalmente recibido (${item.quantity} ${item.unitOfMeasure})',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

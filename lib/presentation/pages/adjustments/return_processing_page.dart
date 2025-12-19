import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';
import 'package:posventa/presentation/widgets/sales/returns/processing/return_items_selector.dart';
import 'package:posventa/presentation/widgets/sales/returns/processing/return_summary_card.dart';

class ReturnProcessingPage extends ConsumerStatefulWidget {
  final Sale? sale;

  const ReturnProcessingPage({super.key, this.sale});

  @override
  ConsumerState<ReturnProcessingPage> createState() =>
      _ReturnProcessingPageState();
}

class _ReturnProcessingPageState extends ConsumerState<ReturnProcessingPage> {
  @override
  void initState() {
    super.initState();
    if (widget.sale != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(returnProcessingProvider.notifier).selectSale(widget.sale!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(returnProcessingProvider);
    final statsAsync = ref.watch(todayReturnsStatsProvider);

    // Listen for errors and success messages
    ref.listen<ReturnProcessingState>(returnProcessingProvider, (
      previous,
      next,
    ) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(returnProcessingProvider.notifier).clearError();
      }

      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(width: 12),
                Expanded(child: Text(next.successMessage!)),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1200),
          ),
        );
        ref.read(returnProcessingProvider.notifier).clearSuccess();

        // Capture router before async gap to avoid context usage warning
        final router = GoRouter.of(context);

        // Navigate back to sales history immediately after showing success
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;

          ref.read(returnProcessingProvider.notifier).reset();
          // Use go instead of pop to ensure fresh navigation and data reload
          router.go('/sales-history');
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Procesamiento de Devolución'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (state.selectedSale != null || state.selectedItems.isNotEmpty) {
              _showCancelConfirmation(context);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: _buildReturnProcessingView(state),
      bottomNavigationBar: state.selectedItems.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton.icon(
                  onPressed: state.canProcess && !state.isProcessing
                      ? () => _triggerProcessReturn()
                      : null,
                  icon: state.isProcessing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(
                    state.isProcessing
                        ? 'Procesando...'
                        : 'Procesar Devolución',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _triggerProcessReturn() async {
    final success = await ref
        .read(returnProcessingProvider.notifier)
        .processReturn();

    if (success && mounted) {
      // Success is handled by the provider listener in build
    }
  }

  Widget _buildReturnProcessingView(ReturnProcessingState state) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Sale info card
        if (state.selectedSale == null)
          const Center(child: CircularProgressIndicator())
        else
          _buildSaleInfoCard(state),
        const SizedBox(height: 24),

        // Items selector
        Text(
          'Seleccionar Productos a Devolver',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        const ReturnItemsSelector(),
        const SizedBox(height: 24),

        // Summary and process
        if (state.selectedItems.isNotEmpty) ...[
          const ReturnSummaryCard(),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSaleInfoCard(ReturnProcessingState state) {
    final sale = state.selectedSale!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venta ${sale.saleNumber}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (sale.customerName != null)
                        Text(
                          sale.customerName!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Fecha', _formatDate(sale.saleDate)),
                _buildInfoItem('Total', '\$${sale.total.toStringAsFixed(2)}'),
                _buildInfoItem('Items', '${sale.items.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar devolución?'),
        content: const Text(
          'Se perderán todos los datos ingresados. ¿Desea continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(returnProcessingProvider.notifier).reset();
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}

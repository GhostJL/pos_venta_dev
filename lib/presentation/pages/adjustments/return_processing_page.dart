import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';
import 'package:posventa/presentation/widgets/return_processing/sale_search_widget.dart';
import 'package:posventa/presentation/widgets/return_processing/return_items_selector.dart';
import 'package:posventa/presentation/widgets/return_processing/return_summary_card.dart';

class ReturnProcessingPage extends ConsumerStatefulWidget {
  const ReturnProcessingPage({super.key});

  @override
  ConsumerState<ReturnProcessingPage> createState() =>
      _ReturnProcessingPageState();
}

class _ReturnProcessingPageState extends ConsumerState<ReturnProcessingPage> {
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
            backgroundColor: Colors.red.shade600,
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
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(next.successMessage!)),
              ],
            ),
            backgroundColor: Colors.green.shade600,
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
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
      body: state.selectedSale == null
          ? _buildSaleSelectionView(statsAsync)
          : _buildReturnProcessingView(state),
    );
  }

  Widget _buildSaleSelectionView(AsyncValue<Map<String, dynamic>> statsAsync) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Header with stats
        _buildHeader(statsAsync),
        const SizedBox(height: 32),

        // Search section
        const Text(
          'Buscar Venta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const SaleSearchWidget(),
      ],
    );
  }

  Widget _buildReturnProcessingView(ReturnProcessingState state) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Sale info card
        _buildSaleInfoCard(state),
        const SizedBox(height: 24),

        // Items selector
        const Text(
          'Seleccionar Productos a Devolver',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
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

  Widget _buildHeader(AsyncValue<Map<String, dynamic>> statsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade700.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.keyboard_return_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Devoluciones de Hoy',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                statsAsync.when(
                  data: (stats) => Text(
                    '${stats['count']} devoluciones • \$${stats['total'].toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  error: (_, __) => Text(
                    'Error al cargar estadísticas',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleInfoCard(ReturnProcessingState state) {
    final sale = state.selectedSale!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Colors.orange.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venta ${sale.saleNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (sale.customerName != null)
                        Text(
                          sale.customerName!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ref.read(returnProcessingProvider.notifier).reset();
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Cambiar'),
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
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}

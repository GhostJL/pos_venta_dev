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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    // Listen for errors and success messages
    ref.listen<ReturnProcessingState>(returnProcessingProvider, (
      previous,
      next,
    ) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: cs.error,
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
                Icon(Icons.check_circle, color: cs.onTertiaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    next.successMessage!,
                    style: TextStyle(color: cs.onTertiaryContainer),
                  ),
                ),
              ],
            ),
            backgroundColor: cs.tertiaryContainer,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1200),
          ),
        );
        ref.read(returnProcessingProvider.notifier).clearSuccess();

        final router = GoRouter.of(context);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          ref.read(returnProcessingProvider.notifier).reset();
          router.go('/sales-history');
        });
      }
    });

    if (state.selectedSale == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Procesar Devolución'),
        centerTitle: false,
        backgroundColor: cs.surface,
        scrolledUnderElevation: 0,
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Content
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSaleInfoHeader(context, state.selectedSale!),
                        const SizedBox(height: 24),
                        Text(
                          'Selección de Productos',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ReturnItemsSelector(),
                      ],
                    ),
                  ),
                ),
                // Right Column: Summary Panel
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    border: Border(
                      left: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Resumen',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (state.selectedItems.isNotEmpty)
                                const ReturnSummaryCard()
                              else
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 48,
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 48,
                                          color: cs.outline.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Seleccione productos\npara comenzar',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Fixed Action Button at Bottom Right
                      if (state.selectedItems.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            border: Border(
                              top: BorderSide(
                                color: cs.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
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
                                        cs.onPrimary,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.check_circle_outlined),
                            label: Text(
                              state.isProcessing
                                  ? 'Procesando...'
                                  : 'Confirmar Devolución',
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Mobile/Tablet View
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSaleInfoHeader(context, state.selectedSale!),
                        const SizedBox(height: 24),
                        Text(
                          'Selección de Productos',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ReturnItemsSelector(),
                        const SizedBox(height: 24),
                        if (state.selectedItems.isNotEmpty) ...[
                          Text(
                            'Resumen',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const ReturnSummaryCard(),
                          const SizedBox(height: 100),
                        ],
                      ],
                    ),
                  ),
                ),
                if (state.selectedItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      border: Border(
                        top: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
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
                                    cs.onPrimary,
                                  ),
                                ),
                              )
                            : const Icon(Icons.check_circle_outlined),
                        label: Text(
                          state.isProcessing
                              ? 'Procesando...'
                              : 'Confirmar Devolución',
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSaleInfoHeader(BuildContext context, Sale sale) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long,
              color: cs.onSecondaryContainer,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Venta ${sale.saleNumber}',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSecondaryContainer,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${sale.items.length} productos',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Cliente: ${sale.customerName ?? 'Público General'}',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSecondaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Venta',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSecondaryContainer.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '\$${sale.total.toStringAsFixed(2)}',
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
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

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar proceso?'),
        content: const Text('Se perderá la selección actual. ¿Desea salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(returnProcessingProvider.notifier).reset();
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

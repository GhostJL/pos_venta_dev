import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A reusable widget that handles AsyncValue states consistently.
///
/// This widget eliminates the need to manually handle loading, error, and data
/// states in every page. It provides a consistent UX across the application.
///
/// Example usage:
/// ```dart
/// AsyncValueHandler<List<Product>>(
///   value: ref.watch(productProvider),
///   data: (products) => ProductList(products: products),
///   emptyState: EmptyStateWidget(
///     icon: Icons.inventory_2_outlined,
///     message: 'No products found',
///   ),
/// )
/// ```
class AsyncValueHandler<T> extends StatelessWidget {
  /// The AsyncValue to handle
  final AsyncValue<T> value;

  /// Builder function for the data state
  final Widget Function(T data) data;

  /// Optional widget to show when data is empty (for lists/collections)
  final Widget? emptyState;

  /// Optional function to determine if data is empty
  /// Defaults to checking if data is an empty Iterable
  final bool Function(T data)? isEmpty;

  /// Optional custom loading widget
  final Widget? loadingWidget;

  /// Optional custom error widget builder
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  /// Optional callback for retry action
  final VoidCallback? onRetry;

  /// Whether to wrap the data widget in a RefreshIndicator
  final bool enableRefresh;

  /// Callback for refresh action (required if enableRefresh is true)
  final Future<void> Function()? onRefresh;

  const AsyncValueHandler({
    super.key,
    required this.value,
    required this.data,
    this.emptyState,
    this.isEmpty,
    this.loadingWidget,
    this.errorBuilder,
    this.onRetry,
    this.enableRefresh = false,
    this.onRefresh,
  }) : assert(
         !enableRefresh || onRefresh != null,
         'onRefresh must be provided when enableRefresh is true',
       );

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (d) {
        // Check if data is empty
        final bool dataIsEmpty =
            isEmpty?.call(d) ?? (d is Iterable && d.isEmpty);

        if (dataIsEmpty && emptyState != null) {
          return emptyState!;
        }

        final dataWidget = data(d);

        // Wrap in RefreshIndicator if enabled
        if (enableRefresh && onRefresh != null) {
          return RefreshIndicator(onRefresh: onRefresh!, child: dataWidget);
        }

        return dataWidget;
      },
      loading: () =>
          loadingWidget ?? const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          errorBuilder?.call(error, stackTrace) ??
          _DefaultErrorWidget(error: error, onRetry: onRetry),
    );
  }
}

/// Default error widget with consistent styling
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Error al cargar',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta de nuevo',
            style: TextStyle(fontSize: 13, color: colorScheme.outline),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

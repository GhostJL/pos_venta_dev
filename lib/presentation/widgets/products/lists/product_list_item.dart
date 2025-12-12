import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/product.dart';

const double _kMinStock = 5;
const double _kLowStock = 20;
const double _kItemPadding = 16.0;

class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onMorePressed;
  final VoidCallback? onTap;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onMorePressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(_kItemPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icono de Producto
              _buildProductVisual(theme),
              const SizedBox(width: _kItemPadding),

              // Información del Producto
              Expanded(child: _buildProductInfo(theme, context)),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets de Construcción Privados ---

  Widget _buildProductVisual(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8), // Bordes menos agresivos
      ),
      child: Icon(
        Icons.widgets_rounded,
        size: 32,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildProductInfo(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Nombre y icono de acciones (Énfasis principal)
        Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            _buildTrailing(theme, context),
          ],
        ),
        const SizedBox(height: 4),

        // 2. Precio de Venta (Secundario, animado)
        _buildPriceRow(theme),
        const SizedBox(height: 4),

        // 3. Código y Departamento (Detalle)
        _buildCodeAndDepartment(theme),
      ],
    );
  }

  Widget _buildPriceRow(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Precio con animación de escala
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            alignment: Alignment.centerLeft,
            child: child,
          ),
          child: Text(
            '\$${(product.salePriceCents / 100).toStringAsFixed(2)}',
            key: ValueKey(product.salePriceCents),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),

        // Separador
        if (product.stock != null) ...[
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),

          // Indicador de Stock
          _buildStockChip(theme),
        ],
      ],
    );
  }

  // Chip de Stock con lógica de color
  Widget _buildStockChip(ThemeData theme) {
    final stock = product.stock ?? 0;

    // Lógica para determinar el color
    Color chipColor;
    Color textColor;
    String text;

    if (stock < _kMinStock) {
      // Usar 'error' para bajo/sin stock
      chipColor = theme.colorScheme.errorContainer.withValues(alpha: 0.6);
      textColor = theme.colorScheme.onErrorContainer;
      text = stock == 0 ? 'Sin Stock' : '$stock Uds.';
    } else if (stock >= _kMinStock && stock < _kLowStock) {
      // Usar 'warning' (o un color personalizado como AppTheme.alertWarning)
      chipColor = AppTheme.alertWarning.withValues(alpha: 0.15);
      textColor = AppTheme.alertWarning;
      text = '$stock Uds. (bajas)';
    } else {
      // Usar 'success' (o un color personalizado como AppTheme.actionConfirm)
      chipColor = AppTheme.actionConfirm.withValues(alpha: 0.1);
      textColor = AppTheme.actionConfirm;
      text = '$stock Uds.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCodeAndDepartment(ThemeData theme) {
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        // Código del Producto
        Text(product.code, style: style),

        // Separador condicional y Departamento
        if (product.departmentName?.isNotEmpty == true) ...[
          const SizedBox(width: 8),

          // Separador Vertical
          Container(
            width: 1,
            height: 10,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),

          // Nombre del Departamento
          Expanded(
            child: Text(
              product.departmentName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrailing(ThemeData theme, BuildContext context) {
    // 2. UX en Móviles: Usar un InkWell en lugar de solo el IconButton
    // para aumentar el "hit target" sin aumentar el tamaño visual del icono.
    return InkWell(
      onTap: onMorePressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4.0), // Aumenta el área táctil
        child: Icon(
          Icons
              .more_horiz_rounded, // Icono de 3 puntos más común para "más opciones" en apps modernas
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

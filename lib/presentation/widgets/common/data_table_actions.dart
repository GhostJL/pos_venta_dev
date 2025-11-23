import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';

/// Widget reutilizable para botones de acción en DataTables.
///
/// Este widget proporciona botones consistentes de Editar y Eliminar
/// con verificación de permisos integrada.
class DataTableActions extends StatelessWidget {
  /// Callback para la acción de editar
  final VoidCallback? onEdit;

  /// Callback para la acción de eliminar
  final VoidCallback? onDelete;

  /// Si el usuario tiene permiso para editar
  final bool hasEditPermission;

  /// Si el usuario tiene permiso para eliminar
  final bool hasDeletePermission;

  /// Tooltip personalizado para el botón de editar
  final String? editTooltip;

  /// Tooltip personalizado para el botón de eliminar
  final String? deleteTooltip;

  const DataTableActions({
    super.key,
    this.onEdit,
    this.onDelete,
    this.hasEditPermission = true,
    this.hasDeletePermission = true,
    this.editTooltip,
    this.deleteTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasEditPermission && onEdit != null)
          IconButton(
            icon: const Icon(
              Icons.edit_rounded,
              color: AppTheme.primary,
              size: 20,
            ),
            tooltip: editTooltip ?? 'Editar',
            onPressed: onEdit,
          ),
        if (hasDeletePermission && onDelete != null)
          IconButton(
            icon: const Icon(
              Icons.delete_rounded,
              color: AppTheme.error,
              size: 20,
            ),
            tooltip: deleteTooltip ?? 'Eliminar',
            onPressed: onDelete,
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/presentation/widgets/common/actions/catalog_module_actions_sheet.dart';

class CardBaseModuleWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? departmentName;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isActive;

  const CardBaseModuleWidget({
    required this.icon,
    super.key,
    required this.title,
    this.subtitle,
    this.departmentName,
    this.onEdit,
    this.onDelete,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: isTablet
                ? _buildTabletLayout(context)
                : _buildMobileLayout(context),
          ),
        );
      },
    );
  }

  /// Layout para móvil (vertical)
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con icono y nombre
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    icon,
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            _actionButton(context),
          ],
        ),
        const SizedBox(height: 8),
        // Departamento
        if (subtitle != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle ?? '',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                departmentName ?? '',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        if (subtitle != null) const SizedBox(height: 8),
        // Estado
        _statusChip(),
      ],
    );
  }

  /// Layout para tablet (horizontal en fila)
  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Ícono y título
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (subtitle != null)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                Text(
                  subtitle ?? '',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  departmentName ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        const SizedBox(width: 12),
        Row(mainAxisSize: MainAxisSize.min, children: [_statusChip()]),
        _actionButton(context),
      ],
    );
  }

  /// Chip de estado
  Widget _statusChip() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive
            ? AppTheme.transactionSuccess.withValues(alpha: 0.2)
            : AppTheme.textDisabledLight.withValues(alpha: 0.2),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isActive
              ? AppTheme.transactionSuccess
              : AppTheme.textDisabledLight,
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.more_horiz,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onPressed: () => _showActions(context),
    );
  }

  void _showActions(BuildContext context) {
    if (onEdit == null && onDelete == null) return;

    final isTablet = MediaQuery.of(context).size.width > 600;

    final sheet = CatalogModuleActionsSheet(
      title: title,
      subtitle: subtitle,
      icon: icon,
      isActive: isActive,
      onEdit: onEdit ?? () {},
      onDelete: onDelete ?? () {},
    );

    if (isTablet) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: sheet,
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => sheet,
      );
    }
  }
}

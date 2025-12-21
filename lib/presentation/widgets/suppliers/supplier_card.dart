import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/widgets/common/actions/catalog_module_actions_sheet.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool hasManagePermission;

  const SupplierCard({
    super.key,
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
    this.hasManagePermission = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      child: InkWell(
        onTap: hasManagePermission
            ? () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => CatalogModuleActionsSheet(
                    title: supplier.name,
                    subtitle: 'Código: ${supplier.code}',
                    icon: Icons.business_rounded,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.business_rounded,
                      color: colorScheme.onSecondaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      supplier.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (hasManagePermission)
                    IconButton(
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => CatalogModuleActionsSheet(
                            title: supplier.name,
                            subtitle: 'Código: ${supplier.code}',
                            icon: Icons.business_rounded,
                            onEdit: onEdit,
                            onDelete: onDelete,
                          ),
                        );
                      },
                    ),
                ],
              ),
              if (_hasContactInfo) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (supplier.contactPerson != null &&
                        supplier.contactPerson!.isNotEmpty)
                      _InfoChip(
                        icon: Icons.person_outline_rounded,
                        label: supplier.contactPerson!,
                        colorScheme: colorScheme,
                      ),
                    if (supplier.phone != null && supplier.phone!.isNotEmpty)
                      _InfoChip(
                        icon: Icons.phone_outlined,
                        label: supplier.phone!,
                        colorScheme: colorScheme,
                      ),
                    if (supplier.email != null && supplier.email!.isNotEmpty)
                      _InfoChip(
                        icon: Icons.email_outlined,
                        label: supplier.email!,
                        colorScheme: colorScheme,
                      ),
                  ],
                ),
              ],
              if (supplier.address != null && supplier.address!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        supplier.address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasContactInfo =>
      (supplier.contactPerson != null && supplier.contactPerson!.isNotEmpty) ||
      (supplier.phone != null && supplier.phone!.isNotEmpty) ||
      (supplier.email != null && supplier.email!.isNotEmpty);
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

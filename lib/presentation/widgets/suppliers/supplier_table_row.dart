import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/widgets/common/actions/catalog_module_actions_sheet.dart';
import 'package:posventa/presentation/widgets/common/right_click_menu_wrapper.dart';

class SupplierHeader extends StatelessWidget {
  const SupplierHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 48 + 16), // Logo space
          Expanded(flex: 3, child: _buildHeader(context, 'Proveedor')),
          Expanded(flex: 2, child: _buildHeader(context, 'Contacto')),
          Expanded(flex: 2, child: _buildHeader(context, 'Detalles')),
          const SizedBox(width: 48), // Actions space
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class SupplierTableRow extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool hasManagePermission;

  const SupplierTableRow({
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

    // Define action logic to reuse
    void showActions() {
      if (hasManagePermission) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => CatalogModuleActionsSheet(
            title: supplier.name,
            subtitle: supplier.taxId ?? '',
            icon: Icons.business_rounded,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        );
      }
    }

    return RightClickMenuWrapper(
      onRightClick: showActions,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: hasManagePermission ? onEdit : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar/Logo
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      supplier.name.isNotEmpty
                          ? supplier.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name & Code
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        supplier.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // If supplier had a code? Assuming just name for now or other identifier
                    ],
                  ),
                ),

                // Contact
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (supplier.email != null && supplier.email!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                supplier.email!,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (supplier.phone != null && supplier.phone!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              supplier.phone!,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Details (Address / Tax ID)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (supplier.taxId != null && supplier.taxId!.isNotEmpty)
                        Text(
                          'RFC: ${supplier.taxId}', // Or localized Tax ID label
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      if (supplier.address != null &&
                          supplier.address!.isNotEmpty)
                        Text(
                          supplier.address!,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),

                // Actions
                if (hasManagePermission)
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: showActions,
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/presentation/widgets/common/actions/catalog_module_actions_sheet.dart';

class CustomerCard extends StatefulWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final bool hasManagePermission;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    this.hasManagePermission = true,
  });

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double scale = _isHovering ? 1.02 : 1.0;
    final double elevation = _isHovering ? 4.0 : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(scale, scale, 1.0),
        child: Card(
          elevation: elevation,
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          color: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: _isHovering
                ? BorderSide(color: colorScheme.primary.withValues(alpha: 0.3))
                : BorderSide.none,
          ),
          child: InkWell(
            onTap:
                widget.onTap ??
                (widget.hasManagePermission
                    ? () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => CatalogModuleActionsSheet(
                            title: widget.customer.fullName,
                            subtitle: 'Código: ${widget.customer.code}',
                            icon: Icons.person_rounded,
                            onEdit: widget.onEdit,
                            onDelete: widget.onDelete,
                          ),
                        );
                      }
                    : null),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            widget.customer.firstName.isNotEmpty
                                ? widget.customer.firstName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.customer.fullName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.customer.code,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.hasManagePermission)
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
                                title: widget.customer.fullName,
                                subtitle: 'Código: ${widget.customer.code}',
                                icon: Icons.person_rounded,
                                onEdit: widget.onEdit,
                                onDelete: widget.onDelete,
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
                        if (widget.customer.phone != null &&
                            widget.customer.phone!.isNotEmpty)
                          _InfoChip(
                            icon: Icons.phone_outlined,
                            label: widget.customer.phone!,
                            colorScheme: colorScheme,
                          ),
                        if (widget.customer.email != null &&
                            widget.customer.email!.isNotEmpty)
                          _InfoChip(
                            icon: Icons.email_outlined,
                            label: widget.customer.email!,
                            colorScheme: colorScheme,
                          ),
                      ],
                    ),
                  ],
                  if (widget.customer.businessName != null &&
                      widget.customer.businessName!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.customer.businessName!,
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
        ),
      ),
    );
  }

  bool get _hasContactInfo =>
      (widget.customer.phone != null && widget.customer.phone!.isNotEmpty) ||
      (widget.customer.email != null && widget.customer.email!.isNotEmpty);
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

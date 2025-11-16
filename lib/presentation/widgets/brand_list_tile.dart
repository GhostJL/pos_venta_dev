import 'package:flutter/material.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/domain/entities/brand.dart';

class BrandListTile extends StatelessWidget {
  final Brand brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BrandListTile({
    super.key,
    required this.brand,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      shadowColor: AppTheme.primary.withAlpha(10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        title: Text(
          brand.name,
          style: textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        subtitle: Text(
          'Code: ${brand.code}',
          style: textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: brand.isActive
                    ? AppTheme.success.withAlpha(10)
                    : AppTheme.error.withAlpha(10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                brand.isActive ? 'Active' : 'Inactive',
                style: textTheme.bodySmall?.copyWith(
                  color: brand.isActive ? AppTheme.success : AppTheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primary),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/widgets/common/pages/generic_module_list_page.dart';

class TaxRatePage extends ConsumerStatefulWidget {
  const TaxRatePage({super.key});

  @override
  ConsumerState<TaxRatePage> createState() => _TaxRatePageState();
}

class _TaxRatePageState extends ConsumerState<TaxRatePage> {
  @override
  Widget build(BuildContext context) {
    final taxRates = ref.watch(taxRateListProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return GenericModuleListPage<TaxRate>(
      title: 'Tasas de Impuestos',
      items: taxRates.asData?.value ?? [],
      isLoading: taxRates.isLoading,
      emptyIcon: Icons.percent_rounded,
      emptyMessage: 'No se encontraron impuestos',
      // Provide an empty/noop action if search/add isn't fully supported via standard means or keep standard
      // But TaxRatePage implies no add button in original code? Or maybe I missed it.
      // Original code had no add button in AppBar actions, only search bar.
      // We will keep it read-only/manage via other means if that was the case, or add it if permission exists.
      // Wait, original code: actions: [] (empty).
      // So no Add button.
      addButtonLabel: null,
      onAddPressed: null,
      filterPlaceholder: 'Buscar impuesto...',
      filterCallback: (taxRate, query) =>
          taxRate.name.toLowerCase().contains(query.toLowerCase()) ||
          taxRate.code.toLowerCase().contains(query.toLowerCase()),
      itemBuilder: (context, taxRate) {
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withOpacity(0.6),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.percent_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              taxRate.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taxRate.code,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                if (taxRate.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(taxRate.rate * 100).toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                if (hasManagePermission && !taxRate.isDefault)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) {
                      if (value == 'setDefault') {
                        ref
                            .read(taxRateListProvider.notifier)
                            .setDefaultTaxRate(taxRate.id!);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'setDefault',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Establecer como default'),
                          ],
                        ),
                      ),
                    ],
                  )
                else if (taxRate.isDefault)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

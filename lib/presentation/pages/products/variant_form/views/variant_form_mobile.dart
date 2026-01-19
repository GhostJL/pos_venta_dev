import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/pages/products/variant_form/variant_form_inputs.dart';
import 'package:posventa/domain/entities/unit_of_measure.dart';
import 'package:posventa/presentation/providers/unit_providers.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/presentation/widgets/common/selection_sheet.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_barcode_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_basic_info_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_price_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_settings_section.dart';

class VariantFormMobile extends ConsumerWidget {
  final ProductVariant? variant;
  final int? productId;
  final String? productName;
  final List<ProductVariant>? availableVariants;
  final VariantType? initialType;
  final GlobalKey<FormState> formKey;
  final VariantFormInputs inputs;
  final VoidCallback onSave;

  const VariantFormMobile({
    super.key,
    required this.variant,
    this.productId,
    this.productName,
    this.availableVariants,
    this.initialType,
    required this.formKey,
    required this.inputs,
    required this.onSave,
  });

  Future<void> _showSelectionSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) labelBuilder,
    T? selectedItem,
    required ValueChanged<T?> onSelected,
  }) async {
    final result = await showModalBottomSheet<SelectionSheetResult<T>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SelectionSheet<T>(
        title: title,
        items: items,
        itemLabelBuilder: labelBuilder,
        selectedItem: selectedItem,
        areEqual: (a, b) => labelBuilder(a) == labelBuilder(b),
      ),
    );

    if (result != null) {
      if (result.isCleared) {
        onSelected(null);
      } else if (result.value != null) {
        onSelected(result.value);
      }
    }
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _buildProductHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primaryContainer),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Producto Principal',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  productName!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = variantFormProvider(variant, initialType: initialType);
    final state = ref.watch(provider);
    final isModified = state.isModified;
    final isEditing = variant != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Editar Variante' : 'Nueva Variante',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              state.type == VariantType.sales ? 'Para Venta' : 'Para Compra',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: state.isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton.icon(
                    onPressed: isModified ? onSave : null,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: Text(
                      isEditing ? 'Actualizar' : 'Guardar',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),

      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (productName != null) ...[
                  _buildProductHeader(theme),
                  const SizedBox(height: 24),
                ],

                _buildSectionHeader(
                  context,
                  'Información General',
                  Icons.info_outline_rounded,
                ),
                const SizedBox(height: 16),
                _buildCard(context, child: _buildBasicInfoColumn(context, ref)),
                const SizedBox(height: 32),

                _buildSectionHeader(
                  context,
                  'Precios y Costos',
                  Icons.payments_outlined,
                ),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  child: VariantPriceSection(
                    variant: variant,
                    initialType: initialType,
                    priceController: inputs.priceController,
                    costController: inputs.costController,
                    wholesalePriceController: inputs.wholesaleController,
                    marginController: inputs.marginController,
                    priceFocus: inputs.priceFocus,
                    costFocus: inputs.costFocus,
                    marginFocus: inputs.marginFocus,
                  ),
                ),
                const SizedBox(height: 32),

                _buildSectionHeader(
                  context,
                  'Identificación',
                  Icons.qr_code_scanner_rounded,
                ),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  child: VariantBarcodeSection(
                    variant: variant,
                    initialType: initialType,
                    barcodeController: inputs.barcodeController,
                  ),
                ),

                if (state.type == VariantType.sales) ...[
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    context,
                    'Configuración Adicional',
                    Icons.settings_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context,
                    child: VariantSettingsSection(
                      variant: variant,
                      stockMinController: inputs.stockMinController,
                      stockMaxController: inputs.stockMaxController,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoColumn(BuildContext context, WidgetRef ref) {
    final provider = variantFormProvider(variant, initialType: initialType);
    return Column(
      children: [
        VariantBasicInfoSection(
          variant: variant,
          initialType: initialType,
          availableVariants: availableVariants,
          nameController: inputs.nameController,
          quantityController: inputs.quantityController,
          conversionController: inputs.conversionController,
          imageFile: ref.watch(provider.select((s) => s.imageFile)),
          photoUrl: ref.watch(provider.select((s) => s.photoUrl)),
          onImageSelected: ref.read(provider.notifier).pickImage,
          onRemoveImage: ref.read(provider.notifier).removeImage,
        ),
        const SizedBox(height: 16),
        // Unit and Switches
        Consumer(
          builder: (context, ref, _) {
            final unitsAsync = ref.watch(unitListProvider);
            final selectedUnitId = ref.watch(provider.select((s) => s.unitId));
            final isSoldByWeight = ref.watch(
              provider.select((s) => s.isSoldByWeight),
            );

            return Column(
              children: [
                unitsAsync.when(
                  data: (units) {
                    final selectedUnit = units
                        .cast<UnitOfMeasure?>()
                        .firstWhere(
                          (u) => u?.id == selectedUnitId,
                          orElse: () => null,
                        );
                    return SelectionField(
                      label: 'Unidad de Medida',
                      placeholder: 'Seleccionar unidad',
                      value: selectedUnit?.name,
                      helperText: 'Unidad de venta (ej. Pieza, Kg)',
                      prefixIcon: Icons.scale_rounded,
                      onTap: () => _showSelectionSheet<UnitOfMeasure>(
                        context: context,
                        title: 'Seleccionar Unidad',
                        items: units,
                        labelBuilder: (u) => '${u.name} (${u.code})',
                        selectedItem: selectedUnit,
                        onSelected: (u) =>
                            ref.read(provider.notifier).updateUnitId(u?.id),
                      ),
                      onClear: () =>
                          ref.read(provider.notifier).updateUnitId(null),
                    );
                  },
                  loading: () => SelectionField(
                    label: 'Unidad de Medida',
                    onTap: () {},
                    isLoading: true,
                  ),
                  error: (e, s) => Text('Error al cargar unidades: $e'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text(
                    'Venta a granel / Por peso',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Habilita la captura de peso/cantidad en el punto de venta',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: isSoldByWeight,
                  onChanged: (val) =>
                      ref.read(provider.notifier).updateIsSoldByWeight(val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

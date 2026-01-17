import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_basic_info_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_price_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_barcode_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_settings_section.dart';

import 'package:posventa/domain/entities/unit_of_measure.dart';
import 'package:posventa/presentation/providers/unit_providers.dart';
import 'package:posventa/presentation/widgets/common/selection_sheet.dart';

class VariantFormPage extends ConsumerStatefulWidget {
  final ProductVariant? variant;
  final int? productId;
  final String? productName;
  final List<String>? existingBarcodes;
  final List<ProductVariant>? availableVariants;
  final VariantType? initialType;

  const VariantFormPage({
    super.key,
    this.variant,
    this.productId,
    this.productName,
    this.existingBarcodes,
    this.availableVariants,
    this.initialType,
  });

  @override
  ConsumerState<VariantFormPage> createState() => _VariantFormPageState();
}

class _VariantFormPageState extends ConsumerState<VariantFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late TextEditingController _wholesaleController;
  late TextEditingController _barcodeController;
  late TextEditingController _conversionController;
  late TextEditingController _stockMinController;
  late TextEditingController _stockMaxController;
  late TextEditingController _marginController;

  final _priceFocus = FocusNode();
  final _costFocus = FocusNode();
  final _marginFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final state = ref.read(
      variantFormProvider(widget.variant, initialType: widget.initialType),
    );
    final provider = variantFormProvider(
      widget.variant,
      initialType: widget.initialType,
    );
    _nameController = TextEditingController(text: state.name);
    _quantityController = TextEditingController(text: state.quantity);
    _priceController = TextEditingController(text: state.price);
    _costController = TextEditingController(text: state.cost);
    _wholesaleController = TextEditingController(text: state.wholesalePrice);
    _barcodeController = TextEditingController(text: state.barcode);
    _conversionController = TextEditingController(text: state.conversionFactor);
    _stockMinController = TextEditingController(text: state.stockMin);
    _stockMaxController = TextEditingController(text: state.stockMax);
    _marginController = TextEditingController(text: state.profitMargin);

    // Add listeners sync
    _nameController.addListener(
      () => ref.read(provider.notifier).updateName(_nameController.text),
    );
    _quantityController.addListener(
      () =>
          ref.read(provider.notifier).updateQuantity(_quantityController.text),
    );
    _priceController.addListener(
      () => ref.read(provider.notifier).updatePrice(_priceController.text),
    );
    _costController.addListener(
      () => ref.read(provider.notifier).updateCost(_costController.text),
    );
    _wholesaleController.addListener(
      () => ref
          .read(provider.notifier)
          .updateWholesalePrice(_wholesaleController.text),
    );
    _barcodeController.addListener(
      () => ref.read(provider.notifier).updateBarcode(_barcodeController.text),
    );
    _conversionController.addListener(
      () => ref
          .read(provider.notifier)
          .updateConversionFactor(_conversionController.text),
    );
    _stockMinController.addListener(
      () =>
          ref.read(provider.notifier).updateStockMin(_stockMinController.text),
    );
    _stockMaxController.addListener(
      () =>
          ref.read(provider.notifier).updateStockMax(_stockMaxController.text),
    );
    _marginController.addListener(
      () => ref
          .read(provider.notifier)
          .updateProfitMargin(_marginController.text),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _wholesaleController.dispose();
    _barcodeController.dispose();
    _conversionController.dispose();
    _stockMinController.dispose();
    _stockMaxController.dispose();
    _marginController.dispose();
    _priceFocus.dispose();
    _costFocus.dispose();
    _marginFocus.dispose();
    super.dispose();
  }

  Future<void> _saveVariant() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, revisa los campos marcados.')),
      );
      return;
    }

    final notifier = ref.read(
      variantFormProvider(
        widget.variant,
        initialType: widget.initialType,
      ).notifier,
    );

    final isNewProductContext = widget.productId == 0;

    final newVariant = await notifier.save(
      widget.productId ?? 0,
      widget.existingBarcodes,
      name: _nameController.text,
      quantity: _quantityController.text,
      price: _priceController.text,
      cost: _costController.text,
      wholesalePrice: _wholesaleController.text,
      conversionFactor: _conversionController.text,
      stockMin: _stockMinController.text,
      stockMax: _stockMaxController.text,
      barcode: _barcodeController.text,
      returnVariantOnly: isNewProductContext,
    );

    if (newVariant != null && mounted) {
      if (!isNewProductContext) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Variante guardada con éxito'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      context.pop(newVariant);
    }
  }

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

  void _noOp() {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.variant != null;
    final provider = variantFormProvider(
      widget.variant,
      initialType: widget.initialType,
    );
    final state = ref.watch(provider);
    final isModified = state.isModified;

    // Logic Recalculation Listeners
    ref.listen<VariantFormState>(provider, (prev, next) {
      if (prev?.price != next.price &&
          _priceController.text != next.price &&
          !_priceFocus.hasFocus) {
        _priceController.text = next.price;
      }
      if (prev?.profitMargin != next.profitMargin &&
          _marginController.text != next.profitMargin &&
          !_marginFocus.hasFocus) {
        _marginController.text = next.profitMargin;
      }
      if (prev?.cost != next.cost &&
          _costController.text != next.cost &&
          !_costFocus.hasFocus) {
        _costController.text = next.cost;
      }
    });

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
                    onPressed: isModified ? _saveVariant : null,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : 700,
                    ),
                    child: Column(
                      children: [
                        if (widget.productName != null) ...[
                          _buildProductHeader(theme),
                          const SizedBox(height: 24),
                        ],

                        if (isDesktop)
                          _buildTwoColumnLayout(context, state)
                        else
                          _buildSingleColumnLayout(context, state),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
                  widget.productName!,
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

  Widget _buildTwoColumnLayout(BuildContext context, VariantFormState state) {
    final provider = variantFormProvider(
      widget.variant,
      initialType: widget.initialType,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildSectionHeader(
                context,
                'Información General',
                Icons.info_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildCard(context, child: _buildBasicInfoColumn(context)),

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
                    variant: widget.variant,
                    stockMinController: _stockMinController,
                    stockMaxController: _stockMaxController,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildSectionHeader(
                context,
                'Precios y Costos',
                Icons.payments_outlined,
              ),
              const SizedBox(height: 16),
              _buildCard(
                context,
                child: VariantPriceSection(
                  variant: widget.variant,
                  initialType: widget.initialType,
                  priceController: _priceController,
                  costController: _costController,
                  wholesalePriceController: _wholesaleController,
                  marginController: _marginController,
                  priceFocus: _priceFocus,
                  costFocus: _costFocus,
                  marginFocus: _marginFocus,
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
                  variant: widget.variant,
                  initialType: widget.initialType,
                  barcodeController: _barcodeController,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout(
    BuildContext context,
    VariantFormState state,
  ) {
    final provider = variantFormProvider(
      widget.variant,
      initialType: widget.initialType,
    );
    return Column(
      children: [
        _buildSectionHeader(
          context,
          'Información General',
          Icons.info_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildCard(context, child: _buildBasicInfoColumn(context)),
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
            variant: widget.variant,
            initialType: widget.initialType,
            priceController: _priceController,
            costController: _costController,
            wholesalePriceController: _wholesaleController,
            marginController: _marginController,
            priceFocus: _priceFocus,
            costFocus: _costFocus,
            marginFocus: _marginFocus,
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
            variant: widget.variant,
            initialType: widget.initialType,
            barcodeController: _barcodeController,
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
              variant: widget.variant,
              stockMinController: _stockMinController,
              stockMaxController: _stockMaxController,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBasicInfoColumn(BuildContext context) {
    final provider = variantFormProvider(
      widget.variant,
      initialType: widget.initialType,
    );
    return Column(
      children: [
        VariantBasicInfoSection(
          variant: widget.variant,
          initialType: widget.initialType,
          availableVariants: widget.availableVariants,
          nameController: _nameController,
          quantityController: _quantityController,
          conversionController: _conversionController,
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
                    onTap: _noOp,
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
}

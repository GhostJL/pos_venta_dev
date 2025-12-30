import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_basic_info_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_price_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_barcode_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_settings_section.dart';

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

    // Add listeners to sync with provider
    _nameController.addListener(() {
      ref.read(provider.notifier).updateName(_nameController.text);
    });
    _quantityController.addListener(() {
      ref.read(provider.notifier).updateQuantity(_quantityController.text);
    });
    _priceController.addListener(() {
      ref.read(provider.notifier).updatePrice(_priceController.text);
    });
    _costController.addListener(() {
      ref.read(provider.notifier).updateCost(_costController.text);
    });
    _wholesaleController.addListener(() {
      ref
          .read(provider.notifier)
          .updateWholesalePrice(_wholesaleController.text);
    });
    _barcodeController.addListener(() {
      ref.read(provider.notifier).updateBarcode(_barcodeController.text);
    });
    _conversionController.addListener(() {
      ref
          .read(provider.notifier)
          .updateConversionFactor(_conversionController.text);
    });
    _stockMinController.addListener(() {
      ref.read(provider.notifier).updateStockMin(_stockMinController.text);
    });
    _stockMaxController.addListener(() {
      ref.read(provider.notifier).updateStockMax(_stockMaxController.text);
    });
    _marginController.addListener(() {
      ref.read(provider.notifier).updateProfitMargin(_marginController.text);
    });
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

    // Ensure we capture if this is a new product context
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
      // If passing 0, we expect the notifier to return the constructed variant without saving to DB
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.variant != null;

    // Watch only necessary properties to avoid rebuilds on every typing change
    final provider = variantFormProvider(
      widget.variant,
      initialType: widget.initialType,
    );
    final isSaving = ref.watch(provider.select((s) => s.isSaving));
    final type = ref.watch(provider.select((s) => s.type));
    final isModified = ref.watch(provider.select((s) => s.isModified));

    // Listen for calculated updates
    ref.listen<VariantFormState>(provider, (prev, next) {
      if (prev?.price != next.price && _priceController.text != next.price) {
        if (!_priceFocus.hasFocus) {
          _priceController.text = next.price;
        }
      }
      if (prev?.profitMargin != next.profitMargin &&
          _marginController.text != next.profitMargin) {
        if (!_marginFocus.hasFocus) {
          _marginController.text = next.profitMargin;
        }
      }
      // Cost usually drives others, but if we had reverse logic:
      if (prev?.cost != next.cost && _costController.text != next.cost) {
        if (!_costFocus.hasFocus) {
          _costController.text = next.cost;
        }
      }
    });

    final isNewProductContext = (widget.productId ?? 0) == 0;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing
                  ? 'Editar Variante de ${type == VariantType.sales ? "Venta" : "Compra"}'
                  : 'Nueva Variante de ${type == VariantType.sales ? "Venta" : "Compra"}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.productName != null)
              Text(
                widget.productName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        actions: [
          if (isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (isModified)
            TextButton(
              onPressed: _saveVariant,
              child: Text(
                isNewProductContext ? 'AGREGAR' : 'GUARDAR',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  _buildFormSection(
                    context,
                    title: 'Información General',
                    icon: Icons.info_outline_rounded,
                    child: VariantBasicInfoSection(
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
                  ),

                  _buildFormSection(
                    context,
                    title: 'Precios y Costos',
                    icon: Icons.payments_outlined,
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

                  _buildFormSection(
                    context,
                    title: 'Identificación',
                    icon: Icons.qr_code_scanner_rounded,
                    child: VariantBarcodeSection(
                      variant: widget.variant,
                      initialType: widget.initialType,
                      barcodeController: _barcodeController,
                    ),
                  ),
                  if (type != VariantType.sales)
                    const SizedBox.shrink()
                  else
                    _buildFormSection(
                      context,
                      title: 'Configuración Adicional',
                      icon: Icons.settings_outlined,
                      child: VariantSettingsSection(
                        variant: widget.variant,
                        stockMinController: _stockMinController,
                        stockMaxController: _stockMaxController,
                      ),
                    ),

                  const SizedBox(height: 24),

                  if (isModified)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: isSaving ? null : _saveVariant,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSaving
                            ? CircularProgressIndicator(
                                color: theme.colorScheme.onPrimary,
                              )
                            : Text(
                                isNewProductContext
                                    ? 'Agregar a la Lista'
                                    : (isEditing
                                          ? 'Actualizar Variante'
                                          : 'Crear Variante'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Padding(padding: const EdgeInsets.all(20.0), child: child),
        ],
      ),
    );
  }
}

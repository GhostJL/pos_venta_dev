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

  @override
  void initState() {
    super.initState();
    final state = ref.read(
      variantFormProvider(widget.variant, initialType: widget.initialType),
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
    );

    if (newVariant != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Variante guardada con éxito'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Editar Variante' : 'Nueva Variante',
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
          if (!isSaving)
            TextButton(
              onPressed: _saveVariant,
              child: Text(
                'GUARDAR',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
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
                      availableVariants: widget.availableVariants,
                      nameController: _nameController,
                      quantityController: _quantityController,
                      conversionController: _conversionController,
                    ),
                  ),

                  _buildFormSection(
                    context,
                    title: 'Precios y Costos',
                    icon: Icons.payments_outlined,
                    child: VariantPriceSection(
                      variant: widget.variant,
                      priceController: _priceController,
                      costController: _costController,
                      wholesalePriceController: _wholesaleController,
                    ),
                  ),

                  _buildFormSection(
                    context,
                    title: 'Identificación',
                    icon: Icons.qr_code_scanner_rounded,
                    child: VariantBarcodeSection(
                      variant: widget.variant,
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditing
                                  ? 'Actualizar Variante'
                                  : 'Crear Variante',
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

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          RepaintBoundary(
            child: Padding(padding: const EdgeInsets.all(16.0), child: child),
          ),
        ],
      ),
    );
  }
}

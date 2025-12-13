import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart' as pt;
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
// Importaciones de widgets de sección
import 'package:posventa/presentation/widgets/products/forms/product_form/product_basic_info_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_classification_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_pricing_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_tax_selection.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_variants_list.dart';

// [El resto de ProductFormPage y ProductFormPageState sigue igual hasta _buildSectionTitle]

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  ProductFormPageState createState() => ProductFormPageState();
}

class ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _barcodeController;
  late TextEditingController _descriptionController;
  late TextEditingController _costPriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _wholesalePriceController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Initialize default taxes if new product
    if (widget.product == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeDefaultTaxes();
      });
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.product?.name);
    _codeController = TextEditingController(text: widget.product?.code);
    _barcodeController = TextEditingController(text: widget.product?.barcode);
    _descriptionController = TextEditingController(
      text: widget.product?.description,
    );

    final product = widget.product;
    _costPriceController = TextEditingController(
      text: product != null
          ? (product.costPriceCents / 100).toStringAsFixed(2)
          : '',
    );
    _salePriceController = TextEditingController(
      text: product != null
          ? (product.salePriceCents / 100).toStringAsFixed(2)
          : '',
    );
    _wholesalePriceController = TextEditingController(
      text: product?.wholesalePriceCents != null
          ? (product!.wholesalePriceCents! / 100).toStringAsFixed(2)
          : '',
    );
  }

  void _initializeDefaultTaxes() {
    final taxRates = ref.read(taxRateListProvider).asData?.value;
    if (taxRates != null) {
      final defaultTaxes = taxRates.where((t) => t.isDefault).toList();
      final notifier = ref.read(productFormProvider(widget.product).notifier);

      final currentTaxes = ref
          .read(productFormProvider(widget.product))
          .selectedTaxes;
      if (currentTaxes.isEmpty) {
        final newTaxes = defaultTaxes
            .map(
              (tax) => pt.ProductTax(
                taxRateId: tax.id!,
                applyOrder: 1, // Simplified, or calculate
              ),
            )
            .toList();
        // Fix applyOrder
        for (int i = 0; i < newTaxes.length; i++) {
          newTaxes[i] = newTaxes[i].copyWith(applyOrder: i + 1);
        }
        notifier.setTaxes(newTaxes);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _costPriceController.dispose();
    _salePriceController.dispose();
    _wholesalePriceController.dispose();
    super.dispose();
  }

  Future<void> _openBarcodeScanner() async {
    final result = await context.push<String>('/scanner');
    if (result != null && mounted) {
      _barcodeController.text = result;
    }
  }

  Future<void> _navigateToVariantForm({
    ProductVariant? variant,
    int? index,
  }) async {
    final provider = productFormProvider(widget.product);
    final state = ref.read(provider);

    final existingBarcodes = state.variants
        .where((v) => v.barcode != null && v.barcode!.isNotEmpty)
        .map((v) => v.barcode!)
        .toList();

    final result = await context.push<ProductVariant>(
      '/product-form/variant',
      extra: {
        'variant': variant,
        'productId': widget.product?.id,
        'existingBarcodes': existingBarcodes,
      },
    );

    if (result != null && mounted) {
      final notifier = ref.read(provider.notifier);
      if (index != null) {
        notifier.updateVariant(index, result);
      } else {
        notifier.addVariant(result);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(productFormProvider(widget.product).notifier);

    await notifier.validateAndSubmit(
      name: _nameController.text,
      code: _codeController.text,
      barcode: _barcodeController.text,
      description: _descriptionController.text,
      costPrice: double.tryParse(_costPriceController.text) ?? 0,
      salePrice: double.tryParse(_salePriceController.text) ?? 0,
      wholesalePrice: _wholesalePriceController.text.isNotEmpty
          ? double.tryParse(_wholesalePriceController.text)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = productFormProvider(widget.product);
    final state = ref.watch(provider);
    final taxRatesAsync = ref.watch(taxRateListProvider);
    final isNewProduct = widget.product == null;

    // Listen for success or error
    ref.listen<ProductFormState>(provider, (previous, next) {
      if (next.error != null && (previous?.error != next.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      if (next.isSuccess && !previous!.isSuccess) {
        // Mejor práctica: un mensaje de éxito sutil antes de hacer pop
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNewProduct ? 'Producto Creado' : 'Producto Actualizado',
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 1),
          ),
        );
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewProduct ? 'Nuevo Producto' : 'Editar Producto'),
        actions: [
          if (state.isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_circle_outline_rounded, size: 28),
              onPressed: _submit,
              tooltip: isNewProduct ? 'Crear Producto' : 'Guardar Cambios',
              color: Theme.of(context).colorScheme.primary,
            ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            _buildSectionTitle(context, 'Información Básica'),
            ProductBasicInfoSection(
              nameController: _nameController,
              codeController: _codeController,
              barcodeController: _barcodeController,
              descriptionController: _descriptionController,
              onScanBarcode: _openBarcodeScanner,
              showBarcode: !state.hasVariants,
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest, // Color sutil
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  '¿Este producto tiene variantes?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Habilita opciones como talla, color, etc. (El código de barras principal se mueve a las variantes)',
                  style: TextStyle(fontSize: 12),
                ),
                value: state.hasVariants,
                onChanged: (value) =>
                    ref.read(provider.notifier).setHasVariants(value),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Clasificación'),
            ProductClassificationSection(
              selectedDepartment: state.departmentId,
              selectedCategory: state.categoryId,
              selectedBrand: state.brandId,
              selectedSupplier: state.supplierId,
              onDepartmentChanged: (value) =>
                  ref.read(provider.notifier).setDepartment(value),
              onCategoryChanged: (value) =>
                  ref.read(provider.notifier).setCategory(value),
              onBrandChanged: (value) =>
                  ref.read(provider.notifier).setBrand(value),
              onSupplierChanged: (value) =>
                  ref.read(provider.notifier).setSupplier(value),
            ),
            const SizedBox(height: 32),

            if (!state.hasVariants) ...[
              _buildSectionTitle(context, 'Precios y Unidad'),
              ProductPricingSection(
                selectedUnitId: state.unitId,
                onUnitChanged: (value) =>
                    ref.read(provider.notifier).setUnit(value),
                costPriceController: _costPriceController,
                salePriceController: _salePriceController,
                wholesalePriceController: _wholesalePriceController,
                isSoldByWeight: state.isSoldByWeight,
                onSoldByWeightChanged: (value) =>
                    ref.read(provider.notifier).setSoldByWeight(value),
              ),
            ] else ...[
              _buildSectionTitle(context, 'Unidad de Medida'),
              ProductPricingSection(
                selectedUnitId: state.unitId,
                onUnitChanged: (value) =>
                    ref.read(provider.notifier).setUnit(value),
                costPriceController: _costPriceController,
                salePriceController: _salePriceController,
                wholesalePriceController: _wholesalePriceController,
                isSoldByWeight: state.isSoldByWeight,
                onSoldByWeightChanged: (value) =>
                    ref.read(provider.notifier).setSoldByWeight(value),
                showPrices: false,
              ),
            ],
            const SizedBox(height: 32),

            _buildSectionTitle(context, 'Impuestos'),
            SwitchListTile(
              title: const Text(
                '¿Aplica Impuestos?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: state.usesTaxes,
              onChanged: (value) =>
                  ref.read(provider.notifier).setUsesTaxes(value),
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),
            if (state.usesTaxes) ...[
              const SizedBox(height: 16),
              taxRatesAsync.when(
                data: (taxRates) => ProductTaxSelection(
                  taxRates: taxRates,
                  selectedTaxes: state.selectedTaxes,
                  onTaxesChanged: (taxes) =>
                      ref.read(provider.notifier).setTaxes(taxes),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error al cargar impuestos: $e'),
              ),
            ],
            const SizedBox(height: 32),

            if (state.hasVariants) ...[
              _buildSectionTitle(context, 'Variantes / Presentaciones'),
              ProductVariantsList(
                variants: state.variants,
                onAddVariant: () => _navigateToVariantForm(),
                onEditVariant: (variant, index) =>
                    _navigateToVariantForm(variant: variant, index: index),
                onDeleteVariant: (index) =>
                    ref.read(provider.notifier).removeVariant(index),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final Map<String, IconData> sectionIcons = {
      'Información Básica': Icons.info_outline_rounded,
      'Clasificación': Icons.category_rounded,
      'Precios y Unidad': Icons.monetization_on_outlined,
      'Unidad de Medida': Icons.straighten_rounded,
      'Impuestos': Icons.receipt_long_rounded,
      'Variantes / Presentaciones': Icons.widgets_outlined,
    };

    final icon = sectionIcons[title];

    return Padding(
      // Añadimos padding superior para asegurarnos de que el título esté bien separado de la sección anterior
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary, // Color de acento
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 18, // Ligeramente más grande para jerarquía
              fontWeight:
                  FontWeight.w700, // Más fuerte, pero sin ser negrita pura
              color: Theme.of(
                context,
              ).colorScheme.primary, // Color principal de texto
              letterSpacing: 0.5, // Un toque moderno
            ),
          ),
        ],
      ),
    );
  }
}

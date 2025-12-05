import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart' as pt;
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_basic_info_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_classification_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_pricing_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_tax_selection.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_variants_list.dart';

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
      // We need to convert TaxRate to ProductTax
      // But ProductTax requires taxRateId.
      // The notifier expects List<ProductTax>.
      // The logic in original file was:
      /*
        if (!_selectedTaxes.any((t) => t.taxRateId == tax.id)) {
            _selectedTaxes.add(ProductTax(...));
        }
      */
      // Here we can just set them if the list is empty.
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

    // Listen for success or error
    ref.listen<ProductFormState>(provider, (previous, next) {
      if (next.error != null && (previous?.error != next.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
      if (next.isSuccess && !previous!.isSuccess) {
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Nuevo Producto' : 'Editar Producto',
        ),
        actions: [
          if (state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: _submit,
              tooltip: 'Guardar Producto',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildSectionTitle('Información Básica'),
            const SizedBox(height: 16),
            ProductBasicInfoSection(
              nameController: _nameController,
              codeController: _codeController,
              barcodeController: _barcodeController,
              descriptionController: _descriptionController,
              onScanBarcode: _openBarcodeScanner,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Clasificación'),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            _buildSectionTitle('Precios y Unidad'),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            _buildSectionTitle('Variantes / Presentaciones'),
            const SizedBox(height: 16),
            ProductVariantsList(
              variants: state.variants,
              onAddVariant: () => _navigateToVariantForm(),
              onEditVariant: (variant, index) =>
                  _navigateToVariantForm(variant: variant, index: index),
              onDeleteVariant: (index) =>
                  ref.read(provider.notifier).removeVariant(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

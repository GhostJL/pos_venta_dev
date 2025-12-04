import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/presentation/widgets/product/widgets/product_basic_info_section.dart';
import 'package:posventa/presentation/widgets/product/widgets/product_classification_section.dart';
import 'package:posventa/presentation/widgets/product/widgets/product_pricing_section.dart';
import 'package:posventa/presentation/widgets/product/widgets/product_tax_selection.dart';
import 'package:posventa/presentation/widgets/product/widgets/product_variants_list.dart';

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

  // State
  int? _selectedDepartment;
  int? _selectedCategory;
  int? _selectedBrand;
  int? _selectedSupplier;
  int? _selectedUnitId;
  bool _isSoldByWeight = false;
  bool _isActive = true;
  List<ProductTax> _selectedTaxes = [];
  List<ProductVariant> _variants = [];
  bool _defaultsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeState();
    _initializeDefaultTaxes();
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

  void _initializeState() {
    _selectedDepartment = widget.product?.departmentId;
    _selectedCategory = widget.product?.categoryId;
    _selectedBrand = widget.product?.brandId;
    _selectedSupplier = widget.product?.supplierId;
    _selectedUnitId = widget.product?.unitId;
    _isSoldByWeight = widget.product?.isSoldByWeight ?? false;
    _isActive = widget.product?.isActive ?? true;
    _selectedTaxes = List<ProductTax>.from(widget.product?.productTaxes ?? []);
    _variants = List<ProductVariant>.from(widget.product?.variants ?? []);
    _defaultsInitialized = widget.product != null;
  }

  void _initializeDefaultTaxes() {
    if (!_defaultsInitialized) {
      final taxRates = ref.read(taxRateListProvider).asData?.value;
      if (taxRates != null) {
        final defaultTaxes = taxRates.where((t) => t.isDefault).toList();
        for (final tax in defaultTaxes) {
          if (!_selectedTaxes.any((t) => t.taxRateId == tax.id)) {
            _selectedTaxes.add(
              ProductTax(
                taxRateId: tax.id!,
                applyOrder: _selectedTaxes.length + 1,
              ),
            );
          }
        }
        _defaultsInitialized = true;
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

  // Navigation methods
  Future<void> _openBarcodeScanner() async {
    final result = await context.push<String>('/scanner');
    if (result != null && mounted) {
      setState(() => _barcodeController.text = result);
    }
  }

  Future<void> _navigateToVariantForm({
    ProductVariant? variant,
    int? index,
  }) async {
    final existingBarcodes = _variants
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
      setState(() {
        if (index != null) {
          _variants[index] = result;
        } else {
          _variants.add(result);
        }
      });
    }
  }

  // Validation methods
  Future<bool> _validateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    final costPrice = (double.parse(_costPriceController.text) * 100).toInt();
    final salePrice = (double.parse(_salePriceController.text) * 100).toInt();

    if (salePrice <= costPrice) {
      _showError('El precio de venta debe ser mayor que el precio de costo.');
      return false;
    }

    final productRepo = ref.read(productRepositoryProvider);

    // Validate code uniqueness
    final isCodeUnique = await productRepo.isCodeUnique(
      _codeController.text,
      excludeId: widget.product?.id,
    );
    if (!isCodeUnique) {
      _showError('El Código/SKU ya existe. Debe ser único.');
      return false;
    }

    // Validate barcode uniqueness
    if (_barcodeController.text.isNotEmpty) {
      final isBarcodeUnique = await productRepo.isBarcodeUnique(
        _barcodeController.text,
        excludeId: widget.product?.id,
      );
      if (!isBarcodeUnique) {
        _showError('El Código de Barras ya existe. Debe ser único.');
        return false;
      }
    } else {
      _showError('El Código de Barras es requerido.');
      return false;
    }

    // Validate variant barcodes
    final variantBarcodes = <String>{};
    for (int i = 0; i < _variants.length; i++) {
      final variantBarcode = _variants[i].barcode;
      if (variantBarcode != null && variantBarcode.isNotEmpty) {
        if (variantBarcodes.contains(variantBarcode)) {
          _showError(
            'Código de barras duplicado en variantes: $variantBarcode',
          );
          return false;
        }
        variantBarcodes.add(variantBarcode);

        final isUnique = await productRepo.isBarcodeUnique(
          variantBarcode,
          excludeVariantId: _variants[i].id,
        );
        if (!isUnique) {
          _showError(
            'El código de barras $variantBarcode ya existe en el sistema',
          );
          return false;
        }
      }
    }

    return true;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  // Submit method
  Future<void> _submit() async {
    if (!await _validateProduct()) {
      return;
    }

    final costPrice = (double.parse(_costPriceController.text) * 100).toInt();
    final salePrice = (double.parse(_salePriceController.text) * 100).toInt();

    // Create main variant
    final mainVariant = ProductVariant(
      id: _variants.isNotEmpty ? _variants.first.id : null,
      productId: widget.product?.id ?? 0,
      variantName: 'Estándar',
      quantity: 1.0,
      priceCents: salePrice,
      costPriceCents: costPrice,
      wholesalePriceCents: _wholesalePriceController.text.isNotEmpty
          ? (double.parse(_wholesalePriceController.text) * 100).toInt()
          : null,
      barcode: _barcodeController.text,
      isForSale: true,
    );

    final finalVariants = List<ProductVariant>.from(_variants);
    if (finalVariants.isEmpty) {
      finalVariants.add(mainVariant);
    } else {
      finalVariants[0] = mainVariant;
    }

    final newProduct = Product(
      id: widget.product?.id,
      name: _nameController.text,
      code: _codeController.text,
      description: _descriptionController.text,
      departmentId: _selectedDepartment!,
      categoryId: _selectedCategory!,
      brandId: _selectedBrand,
      supplierId: _selectedSupplier,
      unitId: _selectedUnitId!,
      isSoldByWeight: _isSoldByWeight,
      productTaxes: _selectedTaxes,
      variants: finalVariants,
      isActive: _isActive,
    );

    if (widget.product == null) {
      ref.read(productListProvider.notifier).addProduct(newProduct);
    } else {
      ref.read(productListProvider.notifier).updateProduct(newProduct);
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taxRatesAsync = ref.watch(taxRateListProvider);

    ref.listen(productListProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Nuevo Producto' : 'Editar Producto',
        ),
        actions: [
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
              selectedDepartment: _selectedDepartment,
              selectedCategory: _selectedCategory,
              selectedBrand: _selectedBrand,
              selectedSupplier: _selectedSupplier,
              onDepartmentChanged: (value) =>
                  setState(() => _selectedDepartment = value),
              onCategoryChanged: (value) =>
                  setState(() => _selectedCategory = value),
              onBrandChanged: (value) => setState(() => _selectedBrand = value),
              onSupplierChanged: (value) =>
                  setState(() => _selectedSupplier = value),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Precios y Unidad'),
            const SizedBox(height: 16),
            ProductPricingSection(
              selectedUnitId: _selectedUnitId,
              onUnitChanged: (value) => setState(() => _selectedUnitId = value),
              costPriceController: _costPriceController,
              salePriceController: _salePriceController,
              wholesalePriceController: _wholesalePriceController,
              isSoldByWeight: _isSoldByWeight,
              onSoldByWeightChanged: (value) =>
                  setState(() => _isSoldByWeight = value),
            ),
            const SizedBox(height: 24),
            taxRatesAsync.when(
              data: (taxRates) => ProductTaxSelection(
                taxRates: taxRates,
                selectedTaxes: _selectedTaxes,
                onTaxesChanged: (taxes) =>
                    setState(() => _selectedTaxes = taxes),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error al cargar impuestos: $e'),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Variantes / Presentaciones'),
            const SizedBox(height: 16),
            ProductVariantsList(
              variants: _variants,
              onAddVariant: () => _navigateToVariantForm(),
              onEditVariant: (variant, index) =>
                  _navigateToVariantForm(variant: variant, index: index),
              onDeleteVariant: (index) =>
                  setState(() => _variants.removeAt(index)),
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

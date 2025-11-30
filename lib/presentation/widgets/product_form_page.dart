import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/presentation/providers/providers.dart'; // For productRepositoryProvider
import 'package:posventa/core/theme/theme.dart';
import 'package:go_router/go_router.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  ProductFormPageState createState() => ProductFormPageState();
}

class ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _barcodeController;
  late TextEditingController _descriptionController;
  late TextEditingController _costPriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _wholesalePriceController;

  int? _selectedDepartment;
  int? _selectedCategory;
  int? _selectedBrand;
  int? _selectedSupplier;
  String? _selectedUnit;
  bool _isSoldByWeight = false;
  bool _isActive = true;

  List<ProductTax> _selectedTaxes = [];
  List<ProductVariant> _variants = [];
  bool _defaultsInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _codeController = TextEditingController(text: widget.product?.code);
    _barcodeController = TextEditingController(text: widget.product?.barcode);
    _descriptionController = TextEditingController(
      text: widget.product?.description,
    );
    _costPriceController = TextEditingController(
      text: widget.product != null
          ? (widget.product!.costPriceCents / 100).toStringAsFixed(2)
          : '',
    );
    _salePriceController = TextEditingController(
      text: widget.product != null
          ? (widget.product!.salePriceCents / 100).toStringAsFixed(2)
          : '',
    );
    _wholesalePriceController = TextEditingController(
      text:
          widget.product != null && widget.product!.wholesalePriceCents != null
          ? (widget.product!.wholesalePriceCents! / 100).toStringAsFixed(2)
          : '',
    );

    _selectedDepartment = widget.product?.departmentId;
    _selectedCategory = widget.product?.categoryId;
    _selectedBrand = widget.product?.brandId;
    _selectedSupplier = widget.product?.supplierId;
    _selectedUnit = widget.product?.unitOfMeasure;
    _isSoldByWeight = widget.product?.isSoldByWeight ?? false;
    _isActive = widget.product?.isActive ?? true;

    // Fix TypeError: Create a new mutable list from the source
    // This ensures we are working with List<ProductTax> and not a restricted subtype list
    _selectedTaxes = List<ProductTax>.from(widget.product?.productTaxes ?? []);
    _variants = List<ProductVariant>.from(widget.product?.variants ?? []);

    // Initialize flag. If editing (product != null), we consider defaults "initialized" (or not needed)
    _defaultsInitialized = widget.product != null;

    // Try to initialize defaults if data is already there
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

  void _openBarcodeScanner() async {
    final result = await context.push<String>('/scanner');

    if (result != null && mounted) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  Future<void> _showVariantDialog({ProductVariant? variant, int? index}) async {
    final isEditing = variant != null;
    final descriptionController = TextEditingController(
      text: variant?.description,
    );
    final quantityController = TextEditingController(
      text: variant?.quantity.toString() ?? '1',
    );
    final priceController = TextEditingController(
      text: variant != null
          ? (variant.priceCents / 100).toStringAsFixed(2)
          : '',
    );
    final costController = TextEditingController(
      text: variant != null
          ? (variant.costPriceCents / 100).toStringAsFixed(2)
          : '',
    );
    final barcodeController = TextEditingController(text: variant?.barcode);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEditing ? 'Editar Variante' : 'Nueva Variante',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (ej. Caja con 12)',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad / Factor',
                  helperText: 'Cuántas unidades del producto base contiene',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: costController,
                      decoration: const InputDecoration(
                        labelText: 'Costo',
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio Venta',
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: barcodeController,
                decoration: InputDecoration(
                  labelText: 'Código de Barras (Opcional)',
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      final result = await context.push<String>('/scanner');
                      if (result != null) {
                        barcodeController.text = result;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (descriptionController.text.isEmpty ||
                  quantityController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  costController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor complete los campos requeridos'),
                  ),
                );
                return;
              }

              final newVariant = ProductVariant(
                id: variant?.id,
                productId: widget.product?.id ?? 0, // Temp ID
                description: descriptionController.text,
                quantity: double.parse(quantityController.text),
                priceCents: (double.parse(priceController.text) * 100).toInt(),
                costPriceCents: (double.parse(costController.text) * 100)
                    .toInt(),
                barcode: barcodeController.text.isNotEmpty
                    ? barcodeController.text
                    : null,
              );

              setState(() {
                if (isEditing && index != null) {
                  _variants[index] = newVariant;
                } else {
                  _variants.add(newVariant);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final costPrice = (double.parse(_costPriceController.text) * 100).toInt();
      final salePrice = (double.parse(_salePriceController.text) * 100).toInt();

      if (salePrice <= costPrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El precio de venta debe ser mayor que el precio de costo.',
            ),
          ),
        );
        return;
      }

      // Validate Uniqueness
      final productRepo = ref.read(productRepositoryProvider);

      // Check Code/SKU
      final isCodeUnique = await productRepo.isCodeUnique(
        _codeController.text,
        excludeId: widget.product?.id,
      );
      if (!isCodeUnique) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El Código/SKU ya existe. Debe ser único.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Check Barcode (if provided)
      if (_barcodeController.text.isNotEmpty) {
        final isBarcodeUnique = await productRepo.isBarcodeUnique(
          _barcodeController.text,
          excludeId: widget.product?.id,
        );
        if (!isBarcodeUnique) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El Código de Barras ya existe. Debe ser único.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      } else {
        // User requirement: "el producto debe de tener un codigo de barras"
        // If it's mandatory, we should enforce it here or in validator.
        // The validator currently doesn't enforce it.
        // I'll enforce it here if empty.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El Código de Barras es requerido.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final newProduct = Product(
        id: widget.product?.id,
        name: _nameController.text,
        code: _codeController.text,
        barcode: _barcodeController.text,
        description: _descriptionController.text,
        departmentId: _selectedDepartment!,
        categoryId: _selectedCategory!,
        brandId: _selectedBrand,
        supplierId: _selectedSupplier,
        unitOfMeasure: _selectedUnit!,
        isSoldByWeight: _isSoldByWeight,
        costPriceCents: costPrice,
        salePriceCents: salePrice,
        wholesalePriceCents:
            (double.parse(_wholesalePriceController.text) * 100).toInt(),
        productTaxes: _selectedTaxes,
        variants: _variants,
        isActive: _isActive,
      );

      if (widget.product == null) {
        ref.read(productNotifierProvider.notifier).addProduct(newProduct);
      } else {
        ref.read(productNotifierProvider.notifier).updateProduct(newProduct);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taxRatesAsync = ref.watch(taxRateListProvider);

    ref.listen(taxRateListProvider, (previous, next) {
      if (!_defaultsInitialized && widget.product == null && next.hasValue) {
        final taxRates = next.value!;
        setState(() {
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
        });
      }
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('Información Básica'),
                  const SizedBox(height: 16),
                  if (isSmallScreen) ...[
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Código/SKU',
                        prefixIcon: Icon(Icons.qr_code_rounded),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Código de Barras',
                        prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: AppTheme.primary,
                          ),
                          onPressed: _openBarcodeScanner,
                          tooltip: 'Escanear',
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _codeController,
                            decoration: const InputDecoration(
                              labelText: 'Código/SKU',
                              prefixIcon: Icon(Icons.qr_code_rounded),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _barcodeController,
                            decoration: InputDecoration(
                              labelText: 'Código de Barras',
                              prefixIcon: const Icon(
                                Icons.qr_code_scanner_rounded,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.qr_code_scanner,
                                  color: AppTheme.primary,
                                ),
                                onPressed: _openBarcodeScanner,
                                tooltip: 'Escanear',
                              ),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Producto',
                      prefixIcon: Icon(Icons.label_outline_rounded),
                    ),
                    validator: (value) => value!.isEmpty
                        ? 'Por favor, introduce un nombre'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Clasificación'),
                  const SizedBox(height: 16),
                  if (isSmallScreen) ...[
                    _buildDropdown(
                      ref.watch(departmentListProvider),
                      'Departamento',
                      _selectedDepartment,
                      (val) => setState(() => _selectedDepartment = val),
                      icon: Icons.business_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      ref.watch(categoryListProvider),
                      'Categoría',
                      _selectedCategory,
                      (val) => setState(() => _selectedCategory = val),
                      icon: Icons.category_rounded,
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            ref.watch(departmentListProvider),
                            'Departamento',
                            _selectedDepartment,
                            (val) => setState(() => _selectedDepartment = val),
                            icon: Icons.business_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            ref.watch(categoryListProvider),
                            'Categoría',
                            _selectedCategory,
                            (val) => setState(() => _selectedCategory = val),
                            icon: Icons.category_rounded,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (isSmallScreen) ...[
                    _buildDropdown(
                      ref.watch(brandListProvider),
                      'Marca',
                      _selectedBrand,
                      (val) => setState(() => _selectedBrand = val),
                      isOptional: true,
                      icon: Icons.branding_watermark_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      ref.watch(supplierListProvider),
                      'Proveedor',
                      _selectedSupplier,
                      (val) => setState(() => _selectedSupplier = val),
                      isOptional: true,
                      icon: Icons.local_shipping_rounded,
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            ref.watch(brandListProvider),
                            'Marca',
                            _selectedBrand,
                            (val) => setState(() => _selectedBrand = val),
                            isOptional: true,
                            icon: Icons.branding_watermark_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            ref.watch(supplierListProvider),
                            'Proveedor',
                            _selectedSupplier,
                            (val) => setState(() => _selectedSupplier = val),
                            isOptional: true,
                            icon: Icons.local_shipping_rounded,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Precios y Unidad'),
                  const SizedBox(height: 16),
                  if (isSmallScreen) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        prefixIcon: Icon(Icons.scale_rounded),
                      ),
                      items: ['pieza', 'kg', 'litro', 'caja']
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedUnit = value),
                      validator: (value) => value == null ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Venta por Peso'),
                      value: _isSoldByWeight,
                      activeThumbColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onChanged: (value) =>
                          setState(() => _isSoldByWeight = value),
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unidad',
                              prefixIcon: Icon(Icons.scale_rounded),
                            ),
                            items: ['pieza', 'kg', 'litro', 'caja']
                                .map(
                                  (unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedUnit = value),
                            validator: (value) =>
                                value == null ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Venta por Peso'),
                            value: _isSoldByWeight,
                            activeThumbColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppTheme.borders),
                            ),
                            onChanged: (value) =>
                                setState(() => _isSoldByWeight = value),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (isSmallScreen) ...[
                    TextFormField(
                      controller: _costPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Costo',
                        prefixText: '\$ ',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _salePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Venta',
                        prefixText: '\$ ',
                        prefixIcon: Icon(Icons.sell_rounded),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _wholesalePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Mayorista',
                        prefixText: '\$ ',
                        prefixIcon: Icon(Icons.storefront_rounded),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _costPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Costo',
                              prefixText: '\$ ',
                              prefixIcon: Icon(Icons.attach_money_rounded),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _salePriceController,
                            decoration: const InputDecoration(
                              labelText: 'Venta',
                              prefixText: '\$ ',
                              prefixIcon: Icon(Icons.sell_rounded),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _wholesalePriceController,
                            decoration: const InputDecoration(
                              labelText: 'Mayorista',
                              prefixText: '\$ ',
                              prefixIcon: Icon(Icons.storefront_rounded),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  taxRatesAsync.when(
                    data: (taxRates) => _buildTaxSelection(taxRates),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error al cargar impuestos: $e'),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Variantes / Presentaciones'),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppTheme.borders),
                    ),
                    child: Column(
                      children: [
                        if (_variants.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No hay variantes agregadas',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _variants.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final variant = _variants[index];
                              return ListTile(
                                title: Text(
                                  variant.description ?? 'Sin descripción',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'Factor: ${variant.quantity} | Precio: \$${variant.price.toStringAsFixed(2)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: AppTheme.primary,
                                      ),
                                      onPressed: () => _showVariantDialog(
                                        variant: variant,
                                        index: index,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _variants.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.add_circle_outline,
                            color: AppTheme.primary,
                          ),
                          title: const Text(
                            'Agregar Variante',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => _showVariantDialog(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Producto Activo'),
                    value: _isActive,
                    activeThumbColor: AppTheme.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppTheme.borders),
                    ),
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Guardar Producto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildDropdown(
    AsyncValue<List<dynamic>> asyncValue,
    String label,
    int? currentValue,
    void Function(int?) onChanged, {
    bool isOptional = false,
    IconData? icon,
  }) {
    return asyncValue.when(
      data: (items) => DropdownButtonFormField<int>(
        initialValue: currentValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e.id as int,
                child: Text(e.name as String, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (value) {
          if (!isOptional && value == null) {
            return 'Requerido';
          }
          return null;
        },
        isExpanded: true,
      ),
      loading: () => const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, s) => Text('Error: $e'),
    );
  }

  Widget _buildTaxSelection(List<TaxRate> taxRates) {
    final activeTaxRates = taxRates.where((t) => t.isActive).toList();
    final isExempt = _selectedTaxes.any(
      (pt) =>
          taxRates
              .firstWhere(
                (t) => t.id == pt.taxRateId,
                orElse: () => TaxRate(name: '', code: '', rate: 0),
              )
              .name ==
          'Exento',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Impuestos Aplicables'),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.borders),
          ),
          child: Column(
            children: [
              ...activeTaxRates.map((taxRate) {
                final isDefault = taxRate.isDefault;
                final isSelected = _selectedTaxes.any(
                  (pt) => pt.taxRateId == taxRate.id,
                );

                final isExemptOption = taxRate.name == 'Exento';

                // Logic for enabling/disabling checkboxes
                bool isEnabled = true;

                if (isExemptOption) {
                  // Exempt option is always enabled
                  isEnabled = true;
                } else {
                  if (isExempt) {
                    // If Exempt is selected, others are disabled
                    isEnabled = false;
                  } else {
                    // If not Exempt, Default taxes are mandatory (cannot be unchecked)
                    if (isDefault) {
                      isEnabled = false; // Disabled but checked
                    } else {
                      isEnabled = true;
                    }
                  }
                }

                return CheckboxListTile(
                  title: Text(
                    '${taxRate.name} (${(taxRate.rate * 100).toStringAsFixed(2)}%)',
                  ),
                  value: isSelected,
                  activeColor: AppTheme.primary,
                  onChanged: isEnabled
                      ? (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (isExemptOption) {
                                // If selecting Exempt, clear all others
                                _selectedTaxes.clear();
                              }
                              _selectedTaxes.add(
                                ProductTax(
                                  taxRateId: taxRate.id!,
                                  applyOrder: _selectedTaxes.length + 1,
                                ),
                              );
                            } else {
                              // Unchecking
                              _selectedTaxes.removeWhere(
                                (pt) => pt.taxRateId == taxRate.id,
                              );

                              if (isExemptOption) {
                                // If unchecking Exempt, restore default taxes
                                final defaultTaxes = taxRates
                                    .where((t) => t.isDefault)
                                    .toList();
                                for (final dt in defaultTaxes) {
                                  if (!_selectedTaxes.any(
                                    (t) => t.taxRateId == dt.id,
                                  )) {
                                    _selectedTaxes.add(
                                      ProductTax(
                                        taxRateId: dt.id!,
                                        applyOrder: _selectedTaxes.length + 1,
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                            _updateApplyOrder();
                          });
                        }
                      : null,
                );
              }),
            ],
          ),
        ),
        if (_selectedTaxes.length > 1) ...[
          const SizedBox(height: 16),
          const Text(
            'Orden de Aplicación (Arrastra para reordenar)',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borders),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _selectedTaxes.removeAt(oldIndex);
                  _selectedTaxes.insert(newIndex, item);
                  _updateApplyOrder();
                });
              },
              children: _selectedTaxes.map((pt) {
                final taxRate = taxRates.firstWhere(
                  (t) => t.id == pt.taxRateId,
                  orElse: () => TaxRate(name: 'Desconocido', code: '', rate: 0),
                );
                return ListTile(
                  key: ValueKey(pt.taxRateId),
                  leading: const Icon(Icons.drag_handle_rounded),
                  title: Text('${taxRate.name} ${taxRate.rate}%'),
                  trailing: Chip(
                    label: Text('Orden: ${pt.applyOrder}'),
                    backgroundColor: AppTheme.primary.withAlpha(20),
                    labelStyle: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  void _updateApplyOrder() {
    for (int i = 0; i < _selectedTaxes.length; i++) {
      _selectedTaxes[i] = _selectedTaxes[i].copyWith(applyOrder: i + 1);
    }
  }
}

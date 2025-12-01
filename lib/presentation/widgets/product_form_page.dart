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
import 'package:posventa/presentation/providers/providers.dart'; // For productRepositoryProvider and unitListProvider
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
  int? _selectedUnitId;
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
    _selectedUnitId = widget.product?.unitId;
    _isSoldByWeight = widget.product?.isSoldByWeight ?? false;
    _isActive = widget.product?.isActive ?? true;

    _selectedTaxes = List<ProductTax>.from(widget.product?.productTaxes ?? []);
    _variants = List<ProductVariant>.from(widget.product?.variants ?? []);

    _defaultsInitialized = widget.product != null;

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
    final nameController = TextEditingController(text: variant?.variantName);
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
    bool isForSale = variant?.isForSale ?? true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(
              isEditing ? 'Editar Variante' : 'Nueva Variante',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Variante (ej. Caja con 12)',
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
                      helperText: 'Puede repetirse para agrupar variantes',
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
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Disponible para Venta'),
                    subtitle: const Text(
                      'Si se desactiva, solo servirá para abastecimiento',
                    ),
                    value: isForSale,
                    onChanged: (value) {
                      setStateDialog(() {
                        isForSale = value;
                      });
                    },
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
                  if (nameController.text.isEmpty ||
                      quantityController.text.isEmpty ||
                      priceController.text.isEmpty ||
                      costController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor complete los campos requeridos',
                        ),
                      ),
                    );
                    return;
                  }

                  final newVariant = ProductVariant(
                    id: variant?.id,
                    productId: widget.product?.id ?? 0, // Temp ID
                    variantName: nameController.text,
                    quantity: double.parse(quantityController.text),
                    priceCents: (double.parse(priceController.text) * 100)
                        .toInt(),
                    costPriceCents: (double.parse(costController.text) * 100)
                        .toInt(),
                    barcode: barcodeController.text.isNotEmpty
                        ? barcodeController.text
                        : null,
                    isForSale: isForSale,
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
          );
        },
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

      final productRepo = ref.read(productRepositoryProvider);

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

      // Create main variant from form fields
      final mainVariant = ProductVariant(
        id: _variants.isNotEmpty ? _variants.first.id : null,
        productId: widget.product?.id ?? 0,
        variantName: 'Estándar', // Default name
        quantity: 1.0,
        priceCents: salePrice,
        costPriceCents: costPrice,
        wholesalePriceCents: _wholesalePriceController.text.isNotEmpty
            ? (double.parse(_wholesalePriceController.text) * 100).toInt()
            : null,
        barcode: _barcodeController.text,
        isForSale: true,
      );

      // Update variants list: Ensure the first variant reflects the main form fields
      List<ProductVariant> finalVariants = List.from(_variants);
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
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taxRatesAsync = ref.watch(taxRateListProvider);
    final unitsAsync = ref.watch(unitListProvider);

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
                    unitsAsync.when(
                      data: (units) => DropdownButtonFormField<int>(
                        value: _selectedUnitId,
                        decoration: const InputDecoration(
                          labelText: 'Unidad',
                          prefixIcon: Icon(Icons.scale_rounded),
                        ),
                        items: units
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit.id,
                                child: Text(unit.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedUnitId = value),
                        validator: (value) =>
                            value == null ? 'Requerido' : null,
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (e, s) => Text('Error: $e'),
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
                          child: unitsAsync.when(
                            data: (units) => DropdownButtonFormField<int>(
                              value: _selectedUnitId,
                              decoration: const InputDecoration(
                                labelText: 'Unidad',
                                prefixIcon: Icon(Icons.scale_rounded),
                              ),
                              items: units
                                  .map(
                                    (unit) => DropdownMenuItem(
                                      value: unit.id,
                                      child: Text(unit.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedUnitId = value),
                              validator: (value) =>
                                  value == null ? 'Requerido' : null,
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (e, s) => Text('Error: $e'),
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
                              'No hay variantes adicionales. Se usará la configuración principal.',
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
                                title: Text(variant.variantName),
                                subtitle: Text(
                                  '${variant.quantity} unidades - \$${(variant.priceCents / 100).toStringAsFixed(2)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showVariantDialog(
                                        variant: variant,
                                        index: index,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton.icon(
                            onPressed: () => _showVariantDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Variante'),
                          ),
                        ),
                      ],
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildDropdown<T>(
    AsyncValue<List<T>> asyncValue,
    String label,
    int? selectedValue,
    Function(int?) onChanged, {
    bool isOptional = false,
    required IconData icon,
  }) {
    return asyncValue.when(
      data: (items) {
        return DropdownButtonFormField<int>(
          value: selectedValue,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
          items: items.map((item) {
            // Assuming items have 'id' and 'name' properties
            // We need to use dynamic or a common interface if we want to be type-safe
            // For now, we'll cast to dynamic to access properties
            final dynamicItem = item as dynamic;
            return DropdownMenuItem<int>(
              value: dynamicItem.id,
              child: Text(dynamicItem.name),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isOptional
              ? null
              : (value) => value == null ? 'Requerido' : null,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error loading $label: $e'),
    );
  }

  Widget _buildTaxSelection(List<TaxRate> taxRates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Impuestos'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: taxRates.map((taxRate) {
            final isSelected = _selectedTaxes.any(
              (t) => t.taxRateId == taxRate.id,
            );
            return FilterChip(
              label: Text('${taxRate.name} (${taxRate.rate * 100}%)'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTaxes.add(
                      ProductTax(
                        taxRateId: taxRate.id!,
                        applyOrder: _selectedTaxes.length + 1,
                      ),
                    );
                  } else {
                    _selectedTaxes.removeWhere(
                      (t) => t.taxRateId == taxRate.id,
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

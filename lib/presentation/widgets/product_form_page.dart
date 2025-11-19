import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/app/theme.dart';

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
    _selectedTaxes = widget.product?.productTaxes ?? [];
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

  void _submit() {
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
        isActive: _isActive,
      );

      if (widget.product == null) {
        ref.read(productNotifierProvider.notifier).addProduct(newProduct);
      } else {
        ref.read(productNotifierProvider.notifier).updateProduct(newProduct);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taxRatesAsync = ref.watch(taxRateListProvider);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Información Básica'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Código/SKU',
                        prefixIcon: Icon(Icons.qr_code_rounded),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Código de Barras',
                        prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                      ),
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
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, introduce un nombre' : null,
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Venta por Peso'),
                      value: _isSoldByWeight,
                      activeColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onChanged: (value) =>
                          setState(() => _isSoldByWeight = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Costo',
                        prefixText: '€ ',
                        prefixIcon: Icon(Icons.euro_rounded),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Venta',
                        prefixText: '€ ',
                        prefixIcon: Icon(Icons.sell_rounded),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _wholesalePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Mayorista',
                        prefixText: '€ ',
                        prefixIcon: Icon(Icons.storefront_rounded),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              taxRatesAsync.when(
                data: (taxRates) => _buildTaxSelection(taxRates),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error al cargar impuestos: $e'),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Producto Activo'),
                value: _isActive,
                activeColor: AppTheme.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
        value: currentValue,
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
      (pt) => taxRates.firstWhere((t) => t.id == pt.taxRateId).name == 'Exento',
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
                final isSelected = _selectedTaxes.any(
                  (pt) => pt.taxRateId == taxRate.id,
                );
                return CheckboxListTile(
                  title: Text('${taxRate.name} (${taxRate.rate}%)'),
                  value: isSelected,
                  activeColor: AppTheme.primary,
                  onChanged: isExempt && taxRate.name != 'Exento'
                      ? null
                      : (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (taxRate.name == 'Exento') {
                                _selectedTaxes.clear();
                              }
                              _selectedTaxes.add(
                                ProductTax(
                                  taxRateId: taxRate.id!,
                                  applyOrder: _selectedTaxes.length + 1,
                                ),
                              );
                            } else {
                              _selectedTaxes.removeWhere(
                                (pt) => pt.taxRateId == taxRate.id,
                              );
                            }
                            _updateApplyOrder();
                          });
                        },
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

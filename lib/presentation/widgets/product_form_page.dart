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
            content: Text('El precio de venta debe ser mayor que el precio de costo.'),
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
        title: Text(widget.product == null ? 'Nuevo Producto' : 'Editar Producto'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _submit)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Código/SKU'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, introduce un código' : null,
              ),
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(labelText: 'Código de Barras'),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, introduce un nombre' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              _buildDropdown(
                ref.watch(departmentListProvider),
                'Departamento',
                _selectedDepartment,
                (val) => setState(() => _selectedDepartment = val),
              ),
              _buildDropdown(
                ref.watch(categoryListProvider),
                'Categoría',
                _selectedCategory,
                (val) => setState(() => _selectedCategory = val),
              ),
              _buildDropdown(
                ref.watch(brandListProvider),
                'Marca',
                _selectedBrand,
                (val) => setState(() => _selectedBrand = val),
                isOptional: true,
              ),
              _buildDropdown(
                ref.watch(supplierListProvider),
                'Proveedor',
                _selectedSupplier,
                (val) => setState(() => _selectedSupplier = val),
                isOptional: true,
              ),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                hint: const Text('Unidad de Medida'),
                items: ['pieza', 'kg', 'litro', 'caja']
                    .map(
                      (unit) =>
                          DropdownMenuItem(value: unit, child: Text(unit)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedUnit = value),
                validator: (value) => value == null ? 'Selecciona una unidad' : null,
              ),
              SwitchListTile(
                title: const Text('Vendido por Peso'),
                value: _isSoldByWeight,
                onChanged: (value) => setState(() => _isSoldByWeight = value),
              ),
              TextFormField(
                controller: _costPriceController,
                decoration: const InputDecoration(
                  labelText: 'Precio de Costo',
                  prefixText: '€',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, introduce el precio de costo' : null,
              ),
              TextFormField(
                controller: _salePriceController,
                decoration: const InputDecoration(
                  labelText: 'Precio de Venta',
                  prefixText: '€',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, introduce el precio de venta' : null,
              ),
              TextFormField(
                controller: _wholesalePriceController,
                decoration: const InputDecoration(
                  labelText: 'Precio al por Mayor',
                  prefixText: '€',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, introduce el precio al por mayor' : null,
              ),
              taxRatesAsync.when(
                data: (taxRates) => _buildTaxSelection(taxRates),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error al cargar las tasas de impuestos: $e'),
              ),
              SwitchListTile(
                title: const Text('Producto Activo'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    AsyncValue<List<dynamic>> asyncValue,
    String hint,
    int? currentValue,
    void Function(int?) onChanged, {
    bool isOptional = false,
  }) {
    return asyncValue.when(
      data: (items) => DropdownButtonFormField<int>(
        value: currentValue,
        hint: Text(hint),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e.id as int,
                child: Text(e.name as String),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (value) {
          if (!isOptional && value == null) {
            return 'Por favor, selecciona un $hint';
          }
          return null;
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error al cargar $hint: $e'),
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
        const Text('Impuestos', style: TextStyle(fontWeight: FontWeight.bold)),
        ...activeTaxRates.map((taxRate) {
          final isSelected = _selectedTaxes.any(
            (pt) => pt.taxRateId == taxRate.id,
          );
          return CheckboxListTile(
            title: Text('${taxRate.name} ${taxRate.rate}%'),
            value: isSelected,
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
        if (_selectedTaxes.length > 1)
          ReorderableListView(
            shrinkWrap: true,
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
              final taxRate = taxRates.firstWhere((t) => t.id == pt.taxRateId);
              return ListTile(
                key: ValueKey(pt.taxRateId),
                title: Text('${taxRate.name} ${taxRate.rate}%'),
                trailing: Text('Orden: ${pt.applyOrder}'),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _updateApplyOrder() {
    for (int i = 0; i < _selectedTaxes.length; i++) {
      _selectedTaxes[i] = _selectedTaxes[i].copyWith(applyOrder: i + 1);
    }
  }
}

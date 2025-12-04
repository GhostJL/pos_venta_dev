import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/providers.dart';

class VariantFormPage extends ConsumerStatefulWidget {
  final ProductVariant? variant;
  final int? productId;
  final List<String>? existingBarcodes;

  const VariantFormPage({
    super.key,
    this.variant,
    this.productId,
    this.existingBarcodes,
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
  late TextEditingController _wholesalePriceController;
  late TextEditingController _barcodeController;

  bool _isForSale = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.variant?.variantName);
    _quantityController = TextEditingController(
      text: widget.variant?.quantity.toString() ?? '1',
    );
    _priceController = TextEditingController(
      text: widget.variant != null
          ? (widget.variant!.priceCents / 100).toStringAsFixed(2)
          : '',
    );
    _costController = TextEditingController(
      text: widget.variant != null
          ? (widget.variant!.costPriceCents / 100).toStringAsFixed(2)
          : '',
    );
    _wholesalePriceController = TextEditingController(
      text: widget.variant?.wholesalePriceCents != null
          ? (widget.variant!.wholesalePriceCents! / 100).toStringAsFixed(2)
          : '',
    );
    _barcodeController = TextEditingController(text: widget.variant?.barcode);
    _isForSale = widget.variant?.isForSale ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _wholesalePriceController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _openBarcodeScanner() async {
    final result = await context.push<String>('/scanner');
    if (result != null && mounted) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  Future<String?> _validateBarcodeUniqueness(String barcode) async {
    if (barcode.isEmpty) {
      return 'El código de barras es requerido';
    }

    // Check against existing barcodes in the product
    if (widget.existingBarcodes != null) {
      // If editing, exclude the current variant's barcode
      final barcodesToCheck = widget.variant?.barcode != null
          ? widget.existingBarcodes!
                .where((b) => b != widget.variant!.barcode)
                .toList()
          : widget.existingBarcodes!;

      if (barcodesToCheck.contains(barcode)) {
        return 'Este código de barras ya está en uso por otra variante de este producto';
      }
    }

    // Check database
    final productRepo = ref.read(productRepositoryProvider);
    final isUnique = await productRepo.isBarcodeUnique(
      barcode,
      excludeVariantId: widget.variant?.id,
    );

    if (!isUnique) {
      return 'Este código de barras ya existe en el sistema';
    }

    return null;
  }

  Future<void> _saveVariant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate barcode uniqueness
    final barcodeError = await _validateBarcodeUniqueness(
      _barcodeController.text,
    );
    if (barcodeError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(barcodeError), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final variant = ProductVariant(
      id: widget.variant?.id,
      productId: widget.productId ?? 0,
      variantName: _nameController.text,
      quantity: double.parse(_quantityController.text),
      priceCents: (double.parse(_priceController.text) * 100).toInt(),
      costPriceCents: (double.parse(_costController.text) * 100).toInt(),
      wholesalePriceCents: _wholesalePriceController.text.isNotEmpty
          ? (double.parse(_wholesalePriceController.text) * 100).toInt()
          : null,
      barcode: _barcodeController.text.isNotEmpty
          ? _barcodeController.text
          : null,
      isForSale: _isForSale,
    );

    if (mounted) {
      context.pop(variant);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.variant != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Variante' : 'Nueva Variante'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveVariant,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Información Básica'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Variante',
                helperText: 'Ej: Caja con 12, Paquete de 6, etc.',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Cantidad / Factor',
                helperText: 'Cuántas unidades base contiene esta variante',
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Requerido';
                final number = double.tryParse(value!);
                if (number == null || number <= 0) {
                  return 'Debe ser mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Precios'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Costo',
                      prefixText: '\$ ',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Requerido';
                      final number = double.tryParse(value!);
                      if (number == null || number < 0) {
                        return 'Debe ser mayor o igual a 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio de Venta',
                      prefixText: '\$ ',
                      prefixIcon: Icon(Icons.sell),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Requerido';
                      final number = double.tryParse(value!);
                      if (number == null || number <= 0) {
                        return 'Debe ser mayor a 0';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _wholesalePriceController,
              decoration: const InputDecoration(
                labelText: 'Precio Mayorista (Opcional)',
                prefixText: '\$ ',
                prefixIcon: Icon(Icons.storefront),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value?.isNotEmpty ?? false) {
                  final number = double.tryParse(value!);
                  if (number == null || number < 0) {
                    return 'Debe ser mayor o igual a 0';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Código de Barras'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Código de Barras',
                helperText: 'Debe ser único en todo el sistema',
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _openBarcodeScanner,
                  tooltip: 'Escanear',
                ),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Configuración'),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Disponible para Venta'),
              subtitle: const Text(
                'Si se desactiva, solo servirá para abastecimiento',
              ),
              value: _isForSale,
              activeThumbColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) => setState(() => _isForSale = value),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saveVariant,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Variante'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart' as pt;

import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_basic_info_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_classification_section.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_tax_selection.dart';
import 'package:posventa/presentation/widgets/products/forms/product_form/product_pricing_section.dart';
import 'package:posventa/presentation/pages/products/variant_type_selection_page.dart';

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

  // Controllers required for ProductPricingSection (hidden in this view)
  late TextEditingController _costController;
  late TextEditingController _priceController;
  late TextEditingController _wholesaleController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

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
    // Initialize with empty or existing values if available (though prices not shown here)
    _costController = TextEditingController();
    _priceController = TextEditingController();
    _wholesaleController = TextEditingController();
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
            .map((tax) => pt.ProductTax(taxRateId: tax.id!, applyOrder: 1))
            .toList();
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
    _costController.dispose();
    _priceController.dispose();
    _wholesaleController.dispose();
    super.dispose();
  }

  Future<void> _openBarcodeScanner() async {
    final result = await context.push<String>('/scanner');
    if (result != null && mounted) {
      _barcodeController.text = result;
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final notifier = ref.read(productFormProvider(widget.product).notifier);
    // Values are now in state, so we can call without args or with nulls
    await notifier.validateAndSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final provider = productFormProvider(widget.product);
    final isLoading = ref.watch(provider.select((s) => s.isLoading));
    final isNewProduct = widget.product == null;
    final notifier = ref.read(provider.notifier);

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
      if (next.isSuccess && (previous?.isSuccess != true)) {
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
        title: Text(
          isNewProduct ? 'Registrar Producto' : 'Editar Producto Base',
        ),
        actions: [
          if (isLoading)
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
              showBarcode:
                  false, // Don't show barcode in base product as per request, use Code/SKU
              // Add listeners to sync with provider
              onNameChanged: notifier.setName,
              onCodeChanged: notifier.setCode,
              onBarcodeChanged: notifier.setBarcode,
              onDescriptionChanged: notifier.setDescription,
            ),

            const SizedBox(height: 16),

            Consumer(
              builder: (context, ref, child) {
                final hasExpiration = ref.watch(
                  provider.select((s) => s.hasExpiration),
                );
                return SwitchListTile(
                  title: const Text(
                    '¿Tiene Caducidad?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: hasExpiration,
                  onChanged: (value) =>
                      ref.read(provider.notifier).setHasExpiration(value),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),

            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Clasificación'),
            ProductClassificationSection(product: widget.product),

            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Precios y Unidad'),
            ProductPricingSection(
              product: widget.product,
              costPriceController: _costController,
              salePriceController: _priceController,
              wholesalePriceController: _wholesaleController,
              showPrices: false, // Only show Unit and Weight options
            ),

            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Impuestos'),
            Consumer(
              builder: (context, ref, child) {
                final usesTaxes = ref.watch(
                  provider.select((s) => s.usesTaxes),
                );
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        '¿Aplica Impuestos?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Estos impuestos se aplicarán a todas las variantes',
                      ),
                      value: usesTaxes,
                      onChanged: (value) =>
                          ref.read(provider.notifier).setUsesTaxes(value),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                    if (usesTaxes) ...[
                      const SizedBox(height: 16),
                      ProductTaxSelection(product: widget.product),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            if (!isNewProduct) ...[
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Variantes'),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.layers_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text(
                    'Gestionar Variantes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Configurar variantes de compra y venta',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VariantTypeSelectionPage(product: widget.product!),
                      ),
                    );
                  },
                ),
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'Podrás agregar variantes una vez guardado el producto base.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

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
      'Impuestos': Icons.receipt_long_rounded,
      'Variantes': Icons.layers_outlined,
    };

    final icon = sectionIcons[title];

    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

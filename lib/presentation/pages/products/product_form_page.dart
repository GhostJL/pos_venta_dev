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

    // Pass current controller values to the notifier only on submission
    await notifier.validateAndSubmit(
      name: _nameController.text,
      code: _codeController.text,
      barcode: _barcodeController.text,
      description: _descriptionController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = productFormProvider(widget.product);
    final isLoading = ref.watch(provider.select((s) => s.isLoading));
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
        scrolledUnderElevation: 0,
        title: Text(
          isNewProduct ? 'Registrar Producto' : 'Editar Producto Base',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: Text(
                'GUARDAR',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            _buildFormSection(
              context,
              title: 'Información Básica',
              icon: Icons.info_outline_rounded,
              child: Column(
                children: [
                  ProductBasicInfoSection(
                    nameController: _nameController,
                    codeController: _codeController,
                    barcodeController: _barcodeController,
                    descriptionController: _descriptionController,
                    onScanBarcode: _openBarcodeScanner,
                    imageFile: ref.watch(provider.select((s) => s.imageFile)),
                    photoUrl: ref.watch(provider.select((s) => s.photoUrl)),
                    onImageSelected: ref.read(provider.notifier).pickImage,
                    onRemoveImage: ref.read(provider.notifier).removeImage,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        value: hasExpiration,
                        onChanged: (value) =>
                            ref.read(provider.notifier).setHasExpiration(value),
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
                ],
              ),
            ),

            _buildFormSection(
              context,
              title: 'Clasificación',
              icon: Icons.category_rounded,
              child: ProductClassificationSection(product: widget.product),
            ),

            _buildFormSection(
              context,
              title: 'Precios y Unidad',
              icon: Icons.monetization_on_outlined,
              child: ProductPricingSection(
                product: widget.product,
                costPriceController: _costController,
                salePriceController: _priceController,
                wholesalePriceController: _wholesaleController,
                showPrices: false,
              ),
            ),

            _buildFormSection(
              context,
              title: 'Impuestos',
              icon: Icons.receipt_long_rounded,
              child: Consumer(
                builder: (context, ref, child) {
                  final usesTaxes = ref.watch(
                    provider.select((s) => s.usesTaxes),
                  );
                  return Column(
                    children: [
                      SwitchListTile(
                        title: const Text(
                          '¿Aplica Impuestos?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: const Text(
                          'Estos impuestos se aplicarán a todas las variantes',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: usesTaxes,
                        onChanged: (value) =>
                            ref.read(provider.notifier).setUsesTaxes(value),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (usesTaxes) ...[
                        const SizedBox(height: 16),
                        ProductTaxSelection(product: widget.product),
                      ],
                    ],
                  );
                },
              ),
            ),

            if (!isNewProduct)
              _buildFormSection(
                context,
                title: 'Variantes',
                icon: Icons.layers_outlined,
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VariantTypeSelectionPage(
                            product: widget.product!,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.layers_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gestionar Variantes',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Configurar variantes de compra y venta',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Padding(
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

            const SizedBox(height: 40),
          ],
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

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

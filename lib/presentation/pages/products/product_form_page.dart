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
import 'package:posventa/presentation/widgets/products/forms/product_form/product_variants_list.dart';

import 'package:posventa/domain/entities/product_variant.dart';

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
  late TextEditingController _descriptionController;

  // Controllers required for ProductPricingSection (hidden in this view)
  late TextEditingController _costController;
  late TextEditingController _priceController;
  late TextEditingController _wholesaleController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Listeners to sync with provider
    final notifier = ref.read(productFormProvider(widget.product).notifier);
    _nameController.addListener(() {
      notifier.setName(_nameController.text);
    });
    _codeController.addListener(() {
      notifier.setCode(_codeController.text);
    });
    _descriptionController.addListener(() {
      notifier.setDescription(_descriptionController.text);
    });

    if (widget.product == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeDefaultTaxes();
      });
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.product?.name);
    _codeController = TextEditingController(text: widget.product?.code);
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
    _descriptionController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _wholesaleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, corrija los errores marcados en el formulario.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final notifier = ref.read(productFormProvider(widget.product).notifier);

    // State is already sync'd via listeners
    await notifier.validateAndSubmit();
  }

  void _onEditVariant(ProductVariant variant, int index) async {
    final result = await context.push<ProductVariant>(
      '/product-form/variant',
      extra: {
        'variant': variant,
        'productId': widget.product?.id ?? 0,
        'productName': _nameController.text,
        'availableVariants': ref
            .read(productFormProvider(widget.product))
            .variants,
      },
    );

    if (result != null) {
      if (widget.product != null) {
        // Existing Product: Refresh from DB to sync changes (variant saved directly)
        ref.read(productFormProvider(widget.product).notifier).refreshFromDb();
      } else {
        // New Product: Update local list
        ref
            .read(productFormProvider(widget.product).notifier)
            .updateVariant(index, result);
      }
    }
  }

  void _onAddVariant(VariantType type) async {
    final result = await context.push<ProductVariant>(
      '/product-form/variant',
      extra: {
        'productId': widget.product?.id ?? 0,
        'productName': _nameController.text,
        'initialType': type,
        'availableVariants': ref
            .read(productFormProvider(widget.product))
            .variants,
      },
    );

    if (result != null) {
      if (widget.product != null) {
        // Existing Product: Refresh from DB
        ref.read(productFormProvider(widget.product).notifier).refreshFromDb();
      } else {
        // New Product: Add to local list
        ref
            .read(productFormProvider(widget.product).notifier)
            .addVariant(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = productFormProvider(widget.product);
    final state = ref.watch(provider);
    final isLoading = state.isLoading;
    final isNewProduct = widget.product == null;
    final theme = Theme.of(context);
    final isModified = state.isModified;

    // Listen for success or error
    ref.listen<ProductFormState>(provider, (previous, next) {
      if (next.error != null && (previous?.error != next.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.isSuccess && (previous?.isSuccess != true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNewProduct ? 'Producto Creado' : 'Producto Actualizado',
            ),
            backgroundColor: theme.colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
        context.pop();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    scrolledUnderElevation: 0,
                    title: Text(
                      isNewProduct ? 'Nuevo Producto' : 'Editar Producto',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else if (isModified)
                        TextButton(
                          onPressed: _submit,
                          child: Text(
                            'GUARDAR',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Basic Info Section
                          _buildSectionHeader(
                            context,
                            'Información General',
                            Icons.info_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildCard(
                            child: Column(
                              children: [
                                ProductBasicInfoSection(
                                  nameController: _nameController,
                                  codeController: _codeController,
                                  descriptionController: _descriptionController,
                                  imageFile: ref.watch(
                                    provider.select((s) => s.imageFile),
                                  ),
                                  photoUrl: ref.watch(
                                    provider.select((s) => s.photoUrl),
                                  ),
                                  onImageSelected: ref
                                      .read(provider.notifier)
                                      .pickImage,
                                  onRemoveImage: ref
                                      .read(provider.notifier)
                                      .removeImage,
                                ),
                                const SizedBox(height: 16),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final isActive = ref.watch(
                                      provider.select((s) => s.isActive),
                                    );
                                    return SwitchListTile(
                                      title: const Text(
                                        'Producto Activo',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: const Text(
                                        'Disponible para venta y operaciones',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      value: isActive,
                                      onChanged: ref
                                          .read(provider.notifier)
                                          .setActive,
                                      contentPadding: EdgeInsets.zero,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Classification Section
                          _buildSectionHeader(
                            context,
                            'Organización',
                            Icons.category_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildCard(
                            child: ProductClassificationSection(
                              product: widget.product,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Taxes Section
                          _buildSectionHeader(
                            context,
                            'Impuestos',
                            Icons.receipt_long_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildCard(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final usesTaxes = ref.watch(
                                  provider.select((s) => s.usesTaxes),
                                );
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        'Configura los impuestos aplicables a este producto',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      value: usesTaxes,
                                      onChanged: (value) => ref
                                          .read(provider.notifier)
                                          .setUsesTaxes(value),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    if (usesTaxes) ...[
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      ProductTaxSelection(
                                        product: widget.product,
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Variants Section
                          _buildSectionHeader(
                            context,
                            'Variantes y Presentaciones',
                            Icons.layers_outlined,
                          ),
                          const SizedBox(height: 16),
                          ProductVariantsList(
                            product: widget.product,
                            onAddVariant: _onAddVariant,
                            onEditVariant: _onEditVariant,
                          ),
                          const SizedBox(height: 16),

                          // Quick Actions for adding variants (Simplified)
                          if (isNewProduct || true) // Always show for now
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _onAddVariant(VariantType.sales),
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('Presentación'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: isNewProduct
                                        ? () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Guarda el producto primero para agregar variantes de compra.',
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        : () => _onAddVariant(
                                            VariantType.purchase,
                                          ),
                                    icon: const Icon(
                                      Icons.add_shopping_cart_rounded,
                                    ),
                                    label: const Text('Var. de Compra'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: isModified
                            ? SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton(
                                  onPressed: isLoading ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isLoading
                                      ? CircularProgressIndicator(
                                          color: theme.colorScheme.onPrimary,
                                        )
                                      : Text(
                                          isNewProduct
                                              ? 'Crear Producto'
                                              : 'Guardar Cambios',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

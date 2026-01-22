import 'package:flutter/material.dart';
import 'package:posventa/presentation/pages/products/product_form/product_form_controllers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart' as pt;

import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';
import 'package:posventa/presentation/pages/products/product_form/views/product_form_desktop.dart';
import 'package:posventa/presentation/pages/products/product_form/views/product_form_mobile.dart';

import 'package:posventa/domain/entities/product_variant.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  ProductFormPageState createState() => ProductFormPageState();
}

class ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late ProductFormControllers _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = ProductFormControllers.fromProduct(widget.product);

    // Listeners to sync with provider
    final notifier = ref.read(productFormProvider(widget.product).notifier);
    _controllers.nameController.addListener(() {
      notifier.setName(_controllers.nameController.text);
    });
    _controllers.codeController.addListener(() {
      notifier.setCode(_controllers.codeController.text);
    });
    _controllers.barcodeController.addListener(() {
      notifier.setBarcode(_controllers.barcodeController.text);
    });
    _controllers.descriptionController.addListener(() {
      notifier.setDescription(_controllers.descriptionController.text);
    });

    if (widget.product == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeDefaultTaxes();
      });
    }
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
    _controllers.dispose();
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
    await notifier.validateAndSubmit(
      price: double.tryParse(_controllers.priceController.text),
      cost: double.tryParse(_controllers.costController.text),
      wholesale: double.tryParse(_controllers.wholesaleController.text),

      minStock: double.tryParse(_controllers.minStockController.text),
      maxStock: double.tryParse(_controllers.maxStockController.text),
    );
  }

  void _onEditVariant(ProductVariant variant, int index) async {
    final result = await context.push<ProductVariant>(
      '/product-form/variant',
      extra: {
        'variant': variant,
        'productId': widget.product?.id ?? 0,
        'productName': _controllers.nameController.text,
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
        'productName': _controllers.nameController.text,
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

  void _onGenerateVariants() async {
    final result = await context.push<List<ProductVariant>>(
      '/products/matrix-generator',
      extra: widget.product?.id ?? 0,
    );

    if (result != null && result.isNotEmpty) {
      final notifier = ref.read(productFormProvider(widget.product).notifier);
      for (var variant in result) {
        // Ensure new variants are marked as sales type by default if not specified
        notifier.addVariant(variant.copyWith(type: VariantType.sales));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.length} variantes generadas exitosamente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = productFormProvider(widget.product);
    final theme = Theme.of(context);
    final isNewProduct = widget.product == null || widget.product?.id == null;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return ProductFormDesktop(
            product: widget.product,
            controllers: _controllers,
            formKey: _formKey,
            onSubmit: _submit,
            onEditVariant: _onEditVariant,
            onAddVariant: _onAddVariant,
            onGenerateVariants: _onGenerateVariants,
          );
        } else {
          return ProductFormMobile(
            product: widget.product,
            controllers: _controllers,
            formKey: _formKey,
            onSubmit: _submit,
            onEditVariant: _onEditVariant,
            onAddVariant: _onAddVariant,
            onGenerateVariants: _onGenerateVariants,
          );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/presentation/pages/products/variant_form/variant_form_inputs.dart';
import 'package:posventa/presentation/pages/products/variant_form/views/variant_form_desktop.dart';
import 'package:posventa/presentation/pages/products/variant_form/views/variant_form_mobile.dart';

class VariantFormPage extends ConsumerStatefulWidget {
  final ProductVariant? variant;
  final int? productId;
  final String? productName;
  final List<String>? existingBarcodes;
  final List<ProductVariant>? availableVariants;
  final VariantType? initialType;

  const VariantFormPage({
    super.key,
    this.variant,
    this.productId,
    this.productName,
    this.existingBarcodes,
    this.availableVariants,
    this.initialType,
  });

  @override
  ConsumerState<VariantFormPage> createState() => _VariantFormPageState();
}

class _VariantFormPageState extends ConsumerState<VariantFormPage> {
  final _formKey = GlobalKey<FormState>();
  late VariantFormInputs _inputs;

  @override
  void initState() {
    super.initState();
    final state = ref.read(
      variantFormProvider(widget.variant, initialType: widget.initialType),
    );
    final provider = variantFormProvider(
      widget.variant,
      initialType: widget.initialType,
    );

    _inputs = VariantFormInputs(
      nameController: TextEditingController(text: state.name),
      quantityController: TextEditingController(text: state.quantity),
      priceController: TextEditingController(text: state.price),
      costController: TextEditingController(text: state.cost),
      wholesaleController: TextEditingController(text: state.wholesalePrice),
      barcodeController: TextEditingController(text: state.barcode),
      conversionController: TextEditingController(text: state.conversionFactor),
      stockMinController: TextEditingController(text: state.stockMin),
      stockMaxController: TextEditingController(text: state.stockMax),
      marginController: TextEditingController(text: state.profitMargin),
      priceFocus: FocusNode(),
      costFocus: FocusNode(),
      marginFocus: FocusNode(),
    );

    // Add listeners sync
    _inputs.nameController.addListener(
      () => ref.read(provider.notifier).updateName(_inputs.nameController.text),
    );
    _inputs.quantityController.addListener(
      () => ref
          .read(provider.notifier)
          .updateQuantity(_inputs.quantityController.text),
    );
    _inputs.priceController.addListener(
      () =>
          ref.read(provider.notifier).updatePrice(_inputs.priceController.text),
    );
    _inputs.costController.addListener(
      () => ref.read(provider.notifier).updateCost(_inputs.costController.text),
    );
    _inputs.wholesaleController.addListener(
      () => ref
          .read(provider.notifier)
          .updateWholesalePrice(_inputs.wholesaleController.text),
    );
    _inputs.barcodeController.addListener(
      () => ref
          .read(provider.notifier)
          .updateBarcode(_inputs.barcodeController.text),
    );
    _inputs.conversionController.addListener(
      () => ref
          .read(provider.notifier)
          .updateConversionFactor(_inputs.conversionController.text),
    );
    _inputs.stockMinController.addListener(
      () => ref
          .read(provider.notifier)
          .updateStockMin(_inputs.stockMinController.text),
    );
    _inputs.stockMaxController.addListener(
      () => ref
          .read(provider.notifier)
          .updateStockMax(_inputs.stockMaxController.text),
    );
    _inputs.marginController.addListener(
      () => ref
          .read(provider.notifier)
          .updateProfitMargin(_inputs.marginController.text),
    );
  }

  @override
  void dispose() {
    _inputs.dispose();
    super.dispose();
  }

  Future<void> _saveVariant() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, revisa los campos marcados.')),
      );
      return;
    }

    final notifier = ref.read(
      variantFormProvider(
        widget.variant,
        initialType: widget.initialType,
      ).notifier,
    );

    final isNewProductContext = widget.productId == 0;

    final newVariant = await notifier.save(
      widget.productId ?? 0,
      widget.existingBarcodes,
      name: _inputs.nameController.text,
      quantity: _inputs.quantityController.text,
      price: _inputs.priceController.text,
      cost: _inputs.costController.text,
      wholesalePrice: _inputs.wholesaleController.text,
      conversionFactor: _inputs.conversionController.text,
      stockMin: _inputs.stockMinController.text,
      stockMax: _inputs.stockMaxController.text,
      barcode: _inputs.barcodeController.text,
      returnVariantOnly: isNewProductContext,
    );

    if (newVariant != null && mounted) {
      if (!isNewProductContext) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Variante guardada con éxito'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      context.pop(newVariant);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = variantFormProvider(
      widget.variant,
      initialType: widget.initialType,
    );

    // Logic Recalculation Listeners
    ref.listen<VariantFormState>(provider, (prev, next) {
      if (prev?.price != next.price &&
          _inputs.priceController.text != next.price &&
          !_inputs.priceFocus.hasFocus) {
        _inputs.priceController.text = next.price;
      }
      if (prev?.profitMargin != next.profitMargin &&
          _inputs.marginController.text != next.profitMargin &&
          !_inputs.marginFocus.hasFocus) {
        _inputs.marginController.text = next.profitMargin;
      }
      if (prev?.cost != next.cost &&
          _inputs.costController.text != next.cost &&
          !_inputs.costFocus.hasFocus) {
        _inputs.costController.text = next.cost;
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return VariantFormDesktop(
            variant: widget.variant,
            productId: widget.productId,
            productName: widget.productName,
            availableVariants: widget.availableVariants,
            initialType: widget.initialType,
            formKey: _formKey,
            inputs: _inputs,
            onSave: _saveVariant,
          );
        } else {
          return VariantFormMobile(
            variant: widget.variant,
            productId: widget.productId,
            productName: widget.productName,
            availableVariants: widget.availableVariants,
            initialType: widget.initialType,
            formKey: _formKey,
            inputs: _inputs,
            onSave: _saveVariant,
          );
        }
      },
    );
  }
}

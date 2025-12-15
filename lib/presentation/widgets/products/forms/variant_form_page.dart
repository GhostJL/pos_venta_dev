import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_basic_info_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_price_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_barcode_section.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form/variant_settings_section.dart';

class VariantFormPage extends ConsumerStatefulWidget {
  final ProductVariant? variant;
  final int? productId;
  final List<String>? existingBarcodes;
  final List<ProductVariant>? availableVariants;

  const VariantFormPage({
    super.key,
    this.variant,
    this.productId,
    this.existingBarcodes,
    this.availableVariants,
  });

  @override
  ConsumerState<VariantFormPage> createState() => _VariantFormPageState();
}

class _VariantFormPageState extends ConsumerState<VariantFormPage> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _saveVariant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(variantFormProvider(widget.variant).notifier);
    final newVariant = await notifier.save(
      widget.productId ?? 0,
      widget.existingBarcodes,
    );

    if (newVariant != null && mounted) {
      context.pop(newVariant);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.variant != null;
    final state = ref.watch(variantFormProvider(widget.variant));

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Variante' : 'Nueva Variante'),
        actions: [
          IconButton(
            icon: state.isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.check_circle_outline_rounded, size: 28),
            onPressed: state.isSaving ? null : _saveVariant,
            tooltip: isEditing ? 'Guardar Cambios' : 'Guardar',
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            children: [
              VariantBasicInfoSection(
                variant: widget.variant,
                availableVariants: widget.availableVariants,
              ),
              const SizedBox(height: 24),
              VariantPriceSection(variant: widget.variant),
              const SizedBox(height: 24),
              VariantBarcodeSection(variant: widget.variant),
              const SizedBox(height: 24),
              VariantSettingsSection(variant: widget.variant),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

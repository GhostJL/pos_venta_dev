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

  Future<void> _saveVariant() async {
    if (!_formKey.currentState!.validate()) {
      // Feedback táctico en caso de error
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
    final theme = Theme.of(context);
    final isEditing = widget.variant != null;
    final state = ref.watch(
      variantFormProvider(widget.variant, initialType: widget.initialType),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Fondo limpio
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Editar Variante' : 'Nueva Variante',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.productName != null)
              Text(
                widget.productName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          // Botón de guardado rápido en el AppBar
          if (!state.isSaving)
            TextButton(
              onPressed: _saveVariant,
              child: Text(
                'GUARDAR',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ), // Optimización Tablet
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  _buildFormSection(
                    context,
                    title: 'Información General',
                    icon: Icons.info_outline_rounded,
                    child: VariantBasicInfoSection(
                      variant: widget.variant,
                      availableVariants: widget.availableVariants,
                    ),
                  ),

                  _buildFormSection(
                    context,
                    title: 'Precios y Costos',
                    icon: Icons.payments_outlined,
                    child: VariantPriceSection(variant: widget.variant),
                  ),

                  _buildFormSection(
                    context,
                    title: 'Identificación',
                    icon: Icons.qr_code_scanner_rounded,
                    child: VariantBarcodeSection(variant: widget.variant),
                  ),
                  if (state.type != VariantType.sales)
                    SizedBox.shrink()
                  else
                    _buildFormSection(
                      context,
                      title: 'Configuración Adicional',
                      icon: Icons.settings_outlined,
                      child: VariantSettingsSection(variant: widget.variant),
                    ),

                  const SizedBox(height: 24),

                  // Botón principal de guardado al final del scroll
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: state.isSaving ? null : _saveVariant,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: state.isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditing
                                  ? 'Actualizar Variante'
                                  : 'Crear Variante',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16.0), child: child),
        ],
      ),
    );
  }
}

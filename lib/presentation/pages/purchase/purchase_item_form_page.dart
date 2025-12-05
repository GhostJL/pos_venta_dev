import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/purchase_item_providers.dart';
import 'package:posventa/presentation/providers/purchase_form_provider.dart';
import 'package:posventa/presentation/viewmodels/product_variant_item.dart';
import 'package:posventa/presentation/widgets/purchases/forms/purchase_item_form/product_selection_section.dart';
import 'package:posventa/presentation/widgets/purchases/forms/purchase_item_form/purchase_selection_section.dart';
import 'package:posventa/presentation/widgets/purchases/forms/purchase_item_form/quantity_cost_section.dart';
import 'package:posventa/presentation/widgets/purchases/forms/purchase_item_form/additional_info_section.dart';
import 'package:posventa/presentation/widgets/purchases/forms/purchase_item_form/totals_preview_section.dart';

/// Form page for creating or editing a purchase item
/// Can be used standalone or as part of a purchase creation flow
class PurchaseItemFormPage extends ConsumerStatefulWidget {
  final int? itemId; // null for create, non-null for edit
  final int? purchaseId; // Optional: pre-select purchase

  const PurchaseItemFormPage({super.key, this.itemId, this.purchaseId});

  @override
  ConsumerState<PurchaseItemFormPage> createState() =>
      _PurchaseItemFormPageState();
}

class _PurchaseItemFormPageState extends ConsumerState<PurchaseItemFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _lotNumberController = TextEditingController();

  // Form state
  ProductVariantItem? _selectedItem;
  int? _selectedPurchaseId;
  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();
    _selectedPurchaseId = widget.purchaseId;

    // Load existing item data if editing
    if (widget.itemId != null) {
      _loadItemData();
    }
  }

  Future<void> _loadItemData() async {
    final item = await ref.read(
      purchaseItemByIdProvider(widget.itemId!).future,
    );
    if (item != null && mounted) {
      setState(() {
        _quantityController.text = item.quantity.toString();
        _unitCostController.text = item.unitCost.toStringAsFixed(2);
        // _lotNumberController.text = item.lotNumber ?? '';
        _selectedPurchaseId = item.purchaseId;
        _expirationDate = item.expirationDate;
        // Note: We can't set _selectedProduct here without loading products
        // But we can store the variantId to set it later if needed,
        // or rely on the user re-selecting if they edit.
        // Ideally we should load the product and variant.
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitCostController.dispose();
    _lotNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedItem == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione un producto')));
      return;
    }

    if (_selectedPurchaseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione una compra')));
      return;
    }

    final quantity = double.parse(_quantityController.text);
    final unitCost = double.parse(_unitCostController.text);

    final success = await ref
        .read(purchaseItemFormProvider.notifier)
        .saveItem(
          itemId: widget.itemId,
          purchaseId: _selectedPurchaseId,
          product: _selectedItem!.product,
          variant: _selectedItem!.variant,
          quantity: quantity,
          unitCost: unitCost,
          expirationDate: _expirationDate,
        );

    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.itemId == null
                ? 'Artículo creado exitosamente'
                : 'Artículo actualizado exitosamente',
          ),
        ),
      );
    } else {
      final error = ref.read(purchaseItemFormProvider).error;
      if (error != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(purchaseItemFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.itemId == null
              ? 'Nuevo Artículo de Compra'
              : 'Editar Artículo de Compra',
        ),
        actions: [
          if (!formState.isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveItem,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: formState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductSelectionSection(
                      selectedItem: _selectedItem,
                      onChanged: (value) {
                        setState(() {
                          _selectedItem = value;
                          if (value != null) {
                            // Pre-fill cost from product or variant
                            _unitCostController.text =
                                (value.costPriceCents / 100).toStringAsFixed(2);
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    if (widget.purchaseId == null) ...[
                      PurchaseSelectionSection(
                        selectedPurchaseId: _selectedPurchaseId,
                        onChanged: (value) {
                          setState(() => _selectedPurchaseId = value);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    QuantityCostSection(
                      quantityController: _quantityController,
                      unitCostController: _unitCostController,
                    ),

                    const SizedBox(height: 24),

                    AdditionalInfoSection(
                      expirationDate: _expirationDate,
                      onDateChanged: (picked) {
                        setState(() => _expirationDate = picked);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Rebuild TotalsPreviewSection when text changes
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        _quantityController,
                        _unitCostController,
                      ]),
                      builder: (context, _) {
                        return TotalsPreviewSection(
                          quantity: _quantityController.text,
                          unitCost: _unitCostController.text,
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveItem,
                        icon: const Icon(Icons.save),
                        label: Text(
                          widget.itemId == null
                              ? 'Crear Artículo'
                              : 'Guardar Cambios',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

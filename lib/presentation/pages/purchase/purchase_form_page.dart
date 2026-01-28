import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/purchase_form_provider.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/presentation/widgets/purchases/dialogs/purchase_item_dialog.dart';
import 'package:posventa/presentation/widgets/purchases/forms/purchase_form/purchase_form_mobile_layout.dart';
import 'package:posventa/presentation/widgets/purchases/forms/purchase_form/purchase_form_desktop_layout.dart';
import 'package:posventa/presentation/providers/providers.dart';

class PurchaseFormPage extends ConsumerStatefulWidget {
  const PurchaseFormPage({super.key});

  @override
  ConsumerState<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends ConsumerState<PurchaseFormPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDefaults();
    });
  }

  Future<void> _loadDefaults() async {
    // Set default date
    ref.read(purchaseFormProvider.notifier).setPurchaseDate(DateTime.now());

    // Load active session warehouse
    try {
      final sessionAsync = ref.read(currentCashSessionProvider);
      sessionAsync.whenData((session) async {
        if (session != null) {
          final warehouses = await ref.read(warehouseProvider.future);
          final activeWarehouse = warehouses
              .where((w) => w.id == session.warehouseId)
              .firstOrNull;

          if (activeWarehouse != null) {
            ref
                .read(purchaseFormProvider.notifier)
                .setWarehouse(activeWarehouse);
          }
        }
      });
    } catch (_) {
      // handle error?
    }
  }

  Future<void> _editItem(int index, PurchaseItem item) async {
    try {
      final product = await ref.read(productProvider(item.productId).future);
      if (product != null) {
        final variant = item.variantId != null
            ? product.variants?.where((v) => v.id == item.variantId).firstOrNull
            : null;

        final warehouseId = ref.read(purchaseFormProvider).warehouse?.id;

        if (warehouseId == null) {
          _showSnackBar('Seleccione un almacén primero');
          return;
        }

        if (!mounted) return;

        final result = await showDialog<PurchaseItem>(
          context: context,
          builder: (context) => PurchaseItemDialog(
            warehouseId: warehouseId,
            existingItem: item,
            product: product,
            variant: variant,
          ),
        );

        if (result != null) {
          ref.read(purchaseFormProvider.notifier).updateItem(index, result);
        }
      }
    } catch (_) {
      if (mounted) _showSnackBar('Error cargando producto para edición');
    }
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(purchaseFormProvider.notifier)
        .savePurchase();

    if (success && mounted) {
      context.go('/purchases');
      _showSnackBar('Compra registrada exitosamente');
    } else {
      final error = ref.read(purchaseFormProvider).error;
      if (error != null && mounted) {
        _showSnackBar(error);
        ref.read(purchaseFormProvider.notifier).clearError();
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _onProductSelected(Product product, ProductVariant? variant) {
    ref.read(purchaseFormProvider.notifier).addItemDirectly(product, variant);
    _showSnackBar(
      'Agregado: ${product.name} ${variant != null ? '(${variant.description})' : ''}',
    );
  }

  Future<void> _onQuantityChanged(int index, double quantity) async {
    final item = ref.read(purchaseFormProvider).items[index];
    try {
      final product = await ref.read(productProvider(item.productId).future);
      if (product != null) {
        ref
            .read(purchaseFormProvider.notifier)
            .updateItemQuantity(index, quantity, product);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final formState = ref.watch(purchaseFormProvider);

    if (formState.isLoading &&
        formState.items.isEmpty &&
        formState.warehouse == null) {
      // Only show full loader if initial load
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isMobile) {
      return PurchaseFormMobileLayout(
        formState: formState,
        onProductSelected: _onProductSelected,
        onEditItem: (index) => _editItem(index, formState.items[index]),
        onRemoveItem: (index) =>
            ref.read(purchaseFormProvider.notifier).removeItem(index),
        onQuantityChanged: _onQuantityChanged,
        onSavePurchase: _savePurchase,
        formKey: _formKey,
        onSupplierChanged: (s) {
          if (s != null) ref.read(purchaseFormProvider.notifier).setSupplier(s);
        },
        onInvoiceNumberChanged: (val) {
          ref.read(purchaseFormProvider.notifier).setInvoiceNumber(val);
        },
      );
    }

    return PurchaseFormDesktopLayout(
      formState: formState,
      onProductSelected: _onProductSelected,
      onEditItem: (index) => _editItem(index, formState.items[index]),
      onRemoveItem: (index) =>
          ref.read(purchaseFormProvider.notifier).removeItem(index),
      onQuantityChanged: _onQuantityChanged,
      onSavePurchase: _savePurchase,
      formKey: _formKey,
      onSupplierChanged: (s) {
        if (s != null) ref.read(purchaseFormProvider.notifier).setSupplier(s);
      },
      onInvoiceNumberChanged: (val) {
        ref.read(purchaseFormProvider.notifier).setInvoiceNumber(val);
      },
    );
  }
}

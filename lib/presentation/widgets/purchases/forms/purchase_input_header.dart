import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';

class PurchaseInputHeader extends ConsumerStatefulWidget {
  final Supplier? selectedSupplier;
  final String invoiceNumber;
  final ValueChanged<Supplier?> onSupplierChanged;
  final ValueChanged<String> onInvoiceNumberChanged;

  const PurchaseInputHeader({
    super.key,
    required this.selectedSupplier,
    required this.invoiceNumber,
    required this.onSupplierChanged,
    required this.onInvoiceNumberChanged,
  });

  @override
  ConsumerState<PurchaseInputHeader> createState() =>
      _PurchaseInputHeaderState();
}

class _PurchaseInputHeaderState extends ConsumerState<PurchaseInputHeader> {
  Timer? _debounce;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedSupplier?.name);
    _focusNode = FocusNode();

    // Listen to changes to clear selection if user types something different
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(PurchaseInputHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSupplier != oldWidget.selectedSupplier) {
      if (widget.selectedSupplier != null) {
        if (_controller.text != widget.selectedSupplier!.name) {
          _controller.text = widget.selectedSupplier!.name;
        }
      }
      // If widget.selectedSupplier is null, we don't necessarily clear the text
      // because it might be null due to user typing (partial match).
      // The clear button explicitly clears the controller.
    }
  }

  void _onTextChanged() {
    // If the text doesn't match the selected supplier's name, we should clear the selection
    // to avoid "ghost" selections where the text says one thing but the ID is another.
    if (widget.selectedSupplier != null &&
        _controller.text != widget.selectedSupplier!.name) {
      // Only trigger update if it's not already null (avoid loops if parent sets null logic)
      // However, we can't easily check 'parent state' directly other than widget.selectedSupplier.
      // We must be careful not to trigger infinite loops.
      // Here we just notify parent that selection is gone.
      widget.onSupplierChanged(null);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(supplierListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        suppliersAsync.when(
          data: (suppliers) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return RawAutocomplete<Supplier>(
                  textEditingController: _controller,
                  focusNode: _focusNode,
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text == '') {
                      return const Iterable<Supplier>.empty();
                    }

                    _debounce?.cancel();
                    final completer = Completer<Iterable<Supplier>>();
                    _debounce = Timer(const Duration(seconds: 1), () {
                      final options = suppliers.where((Supplier option) {
                        return option.name.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                      completer.complete(options);
                    });

                    return completer.future;
                  },
                  displayStringForOption: (Supplier option) => option.name,
                  onSelected: (Supplier selection) {
                    widget.onSupplierChanged(selection);
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        return TextFormField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Buscador de Proveedores',
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                            border: const OutlineInputBorder(),
                            suffixIcon:
                                fieldTextEditingController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      fieldTextEditingController.clear();
                                      widget.onSupplierChanged(null);
                                    },
                                  )
                                : const Icon(Icons.arrow_drop_down),
                          ),
                        );
                      },
                  optionsViewBuilder:
                      (
                        BuildContext context,
                        AutocompleteOnSelected<Supplier> onSelected,
                        Iterable<Supplier> options,
                      ) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Supplier option = options.elementAt(
                                    index,
                                  );
                                  return ListTile(
                                    title: Text(option.name),
                                    onTap: () {
                                      onSelected(option);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                );
              },
            );
          },
          loading: () => const LinearProgressIndicator(minHeight: 2),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: widget.invoiceNumber,
          decoration: const InputDecoration(
            labelText: 'N° Factura',
            prefixIcon: Icon(Icons.receipt_long_outlined),
            hintText: 'Opcional',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged: widget.onInvoiceNumberChanged,
        ),
      ],
    );
  }
}

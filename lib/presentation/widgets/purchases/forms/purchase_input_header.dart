import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';

class PurchaseInputHeader extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(supplierListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        suppliersAsync.when(
          data: (suppliers) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete<Supplier>(
                  initialValue: TextEditingValue(
                    text: selectedSupplier?.name ?? '',
                  ),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<Supplier>.empty();
                    }
                    return suppliers.where((Supplier option) {
                      return option.name.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  displayStringForOption: (Supplier option) => option.name,
                  onSelected: (Supplier selection) {
                    onSupplierChanged(selection);
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        if (selectedSupplier != null &&
                            fieldTextEditingController.text !=
                                selectedSupplier!.name) {
                          fieldTextEditingController.text =
                              selectedSupplier!.name;
                        }
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
                                      onSupplierChanged(null);
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
          initialValue: invoiceNumber,
          decoration: const InputDecoration(
            labelText: 'N° Factura',
            prefixIcon: Icon(Icons.receipt_long_outlined),
            hintText: 'Opcional',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onChanged: onInvoiceNumberChanged,
        ),
      ],
    );
  }
}

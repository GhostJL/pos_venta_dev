import 'package:flutter/material.dart';
import 'package:posventa/presentation/mixins/search_debounce_mixin.dart';

class PurchaseItemsSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const PurchaseItemsSearchBar({super.key, required this.onChanged});

  @override
  State<PurchaseItemsSearchBar> createState() => _PurchaseItemsSearchBarState();
}

class _PurchaseItemsSearchBarState extends State<PurchaseItemsSearchBar>
    with SearchDebounceMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por producto...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        onChanged: (value) {
          debounceSearch(() {
            widget.onChanged(value);
          });
        },
      ),
    );
  }
}

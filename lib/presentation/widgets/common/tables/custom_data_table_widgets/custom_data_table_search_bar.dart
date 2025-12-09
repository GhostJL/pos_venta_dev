import 'package:flutter/material.dart';
import 'package:posventa/presentation/mixins/search_debounce_mixin.dart';

class CustomDataTableSearchBar extends StatefulWidget {
  final ValueChanged<String>? onSearch;

  const CustomDataTableSearchBar({super.key, required this.onSearch});

  @override
  State<CustomDataTableSearchBar> createState() =>
      _CustomDataTableSearchBarState();
}

class _CustomDataTableSearchBarState extends State<CustomDataTableSearchBar>
    with SearchDebounceMixin {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        debounceSearch(() {
          widget.onSearch?.call(value);
        });
      },
      decoration: InputDecoration(
        hintText: 'Buscar...',
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        isDense: true,
      ),
    );
  }
}

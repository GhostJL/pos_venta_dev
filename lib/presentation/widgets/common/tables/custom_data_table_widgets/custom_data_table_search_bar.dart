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
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      onChanged: (value) {
        debounceSearch(() {
          widget.onSearch?.call(value);
        });
      },
      decoration: InputDecoration(
        hintText: 'Buscar...',
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withAlpha(150),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colorScheme.primary,
          size: 20,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(100),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colorScheme.primary, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        isDense: true,
      ),
    );
  }
}

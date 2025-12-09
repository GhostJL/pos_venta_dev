import 'package:flutter/material.dart';
import 'package:posventa/presentation/mixins/search_debounce_mixin.dart';

class SideMenuSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String searchQuery;
  final VoidCallback onClear;

  const SideMenuSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.searchQuery,
    required this.onClear,
  });

  @override
  State<SideMenuSearchBar> createState() => _SideMenuSearchBarState();
}

class _SideMenuSearchBarState extends State<SideMenuSearchBar>
    with SearchDebounceMixin {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withAlpha(100)),
        ),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: (value) {
          debounceSearch(() {
            widget.onChanged(value);
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar en menú...',
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  onPressed: widget.onClear,
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

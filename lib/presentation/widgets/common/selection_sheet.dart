import 'package:flutter/material.dart';

/// Result object returned by SelectionSheet
class SelectionSheetResult<T> {
  final T? value;
  final bool isCleared;

  const SelectionSheetResult({this.value, this.isCleared = false});
}

/// A generic searchable bottom sheet for selection.
class SelectionSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final T? selectedItem;
  final bool Function(T, T)? areEqual;
  final VoidCallback? onAdd;

  const SelectionSheet({
    super.key,
    required this.title,
    required this.items,
    required this.itemLabelBuilder,
    this.selectedItem,
    this.areEqual,
    this.onAdd,
  });

  @override
  State<SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<SelectionSheet<T>> {
  late List<T> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          return widget
              .itemLabelBuilder(item)
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Wrap in Material to ensure TextField has a Material ancestor
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Drag handle
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (widget.onAdd != null) ...[
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        // Close sheet then trigger add? Or trigger add above sheet?
                        // If we trigger add, it opens a dialog. Dialogs can be above sheets.
                        // But if we want to refresh the list after adding, we might need to close/reopen or have the parent update the list.
                        // `onAdd` callback from parent usually opens the form.
                        // The form updates the provider.
                        // The provider update triggers a rebuild of the parent.
                        // But `SelectionSheet` uses `widget.items` which is passed in.
                        // If the list updates, does `SelectionSheet` update?
                        // `_filteredItems` is initialized in `initState`. It won't update if parent rebuilds unless we use `didUpdateWidget`.
                        // For now, let's keep it simple: Action executes.
                        widget.onAdd!();
                      },
                      style: IconButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                onChanged: _filter,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            // Items List
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron resultados',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final label = widget.itemLabelBuilder(item);
                        final isSelected =
                            widget.selectedItem != null &&
                            (widget.areEqual?.call(
                                  widget.selectedItem as T,
                                  item,
                                ) ??
                                widget.selectedItem == item);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // If already selected, return explicit clear
                              if (isSelected) {
                                Navigator.pop(
                                  context,
                                  SelectionSheetResult<T>(
                                    value: null,
                                    isCleared: true,
                                  ),
                                );
                              } else {
                                Navigator.pop(
                                  context,
                                  SelectionSheetResult<T>(value: item),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onSurface,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Bottom safe area padding
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}

/// A read-only text field that simulates a dropdown/selector by opening a SelectionSheet on tap.
class SelectionField extends StatelessWidget {
  final String label;
  final String? value;
  final String? helperText;
  final String? placeholder;
  final VoidCallback onTap;
  final VoidCallback? onClear; // Added
  final String? Function(String?)? validator;
  final String? errorMessage;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final bool isLoading;

  const SelectionField({
    super.key,
    required this.label,
    required this.onTap,
    this.onClear, // Added
    this.value,
    this.helperText,
    this.placeholder,
    this.errorMessage,
    this.suffixIcon,
    this.prefixIcon,
    this.isLoading = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorMessage != null;
    final showClearButton =
        onClear != null && value != null && value!.isNotEmpty;

    return TextFormField(
      key: ValueKey(value),
      initialValue: value,
      readOnly: true,
      onTap: isLoading ? null : onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder ?? 'Seleccionar...', // Default placeholder
        helperText: helperText,
        errorText: errorMessage,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLowest,
        prefixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : (prefixIcon != null
                  ? Icon(prefixIcon, color: theme.colorScheme.primary)
                  : null),
        suffixIcon:
            suffixIcon ??
            (showClearButton
                ? IconButton(
                    icon: Icon(
                      Icons.highlight_remove_rounded, // Clear icon
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onClear,
                  )
                : Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
      ),
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      validator: validator ?? (val) => errorMessage,
    );
  }
}

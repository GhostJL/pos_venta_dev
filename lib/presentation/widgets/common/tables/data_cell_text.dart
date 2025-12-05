import 'package:flutter/material.dart';

/// Standardized text widgets for DataTable cells.
///
/// These widgets ensure consistent styling across all catalog pages
/// and reduce code duplication.

/// Primary text for DataTable cells (names, titles)
/// Bold and uses onSurface color
class DataCellPrimaryText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const DataCellPrimaryText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return Text(text, style: style ?? defaultStyle);
  }
}

/// Secondary text for DataTable cells (codes, descriptions)
/// Regular weight and uses onSurfaceVariant color
class DataCellSecondaryText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const DataCellSecondaryText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Text(text, style: style ?? defaultStyle);
  }
}

/// Monospace text for DataTable cells (phone numbers, IDs)
/// Uses monospace font family
class DataCellMonospaceText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const DataCellMonospaceText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = const TextStyle(fontFamily: 'Monospace');

    return Text(text, style: style ?? defaultStyle);
  }
}

/// Link-styled text for DataTable cells (emails, URLs)
/// Uses primary color to indicate clickability
class DataCellLinkText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final VoidCallback? onTap;

  const DataCellLinkText(this.text, {super.key, this.style, this.onTap});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );

    final widget = Text(text, style: style ?? defaultStyle);

    if (onTap != null) {
      return InkWell(onTap: onTap, child: widget);
    }

    return widget;
  }
}

/// Regular text for DataTable cells
/// Uses default body text style
class DataCellText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const DataCellText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style);
  }
}

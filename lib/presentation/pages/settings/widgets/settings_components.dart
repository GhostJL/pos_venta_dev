import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  final String title;

  const SettingsHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        top: 24.0,
        bottom: 8.0,
        right: 16.0,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SettingsCategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  const SettingsCategoryTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        selected: selected,
        selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary
                : colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(
            icon,
            color: selected ? colorScheme.onPrimary : colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colorScheme.outline.withValues(alpha: 0.5),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}

class SettingsToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

class SettingsSectionContainer extends StatelessWidget {
  final List<Widget> children;

  const SettingsSectionContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(children: children),
    );
  }
}

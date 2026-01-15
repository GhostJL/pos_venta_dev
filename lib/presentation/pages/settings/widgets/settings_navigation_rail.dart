import 'package:flutter/material.dart';

class SettingsNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;

  const SettingsNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      // backgroundColor: Theme.of(context).colorScheme.surface,
      destinations: destinations,
      // extended: true, // Optional: make it expandable or always extended
    );
  }
}

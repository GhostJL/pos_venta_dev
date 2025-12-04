import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/menu/side_menu.dart';
import 'package:posventa/presentation/widgets/common/theme_toggle_button.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 768;

        if (isSmallScreen) {
          return Scaffold(
            appBar: AppBar(
              forceMaterialTransparency: true,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: const [ThemeToggleButton()],
            ),
            drawer: const Drawer(elevation: 0, child: SideMenu()),
            body: child,
          );
        } else {
          return Scaffold(
            body: Row(
              children: [
                const SideMenu(),
                Expanded(child: child),
              ],
            ),
          );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/menu/side_menu.dart';
import 'package:posventa/core/theme/theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 768;

        if (isSmallScreen) {
          return Scaffold(
            appBar: AppBar(
              forceMaterialTransparency: true,
              backgroundColor: AppTheme.background,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: AppTheme.textPrimary,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            drawer: const Drawer(elevation: 0, child: SideMenu()),
            body: child,
          );
        } else {
          return Scaffold(
            backgroundColor: AppTheme.background,
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

import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/side_menu.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to create a responsive layout
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define a breakpoint for small screens (e.g., mobile phones)
        final bool isSmallScreen = constraints.maxWidth < 768;

        if (isSmallScreen) {
          // For small screens, use a Scaffold with a Drawer
          return Scaffold(
            appBar: AppBar(
              // The AppBar can be customized as needed
            ),
            drawer: const Drawer(child: SideMenu()),
            body: child,
          );
        } else {
          // For larger screens, use a Row with a fixed side menu
          return Scaffold(
            body: Row(
              children: [
                const SideMenu(),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: child),
              ],
            ),
          );
        }
      },
    );
  }
}

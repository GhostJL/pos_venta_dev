import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/widgets/menu/side_menu.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final ValueNotifier<bool> _isMenuVisible = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _isMenuVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyV, alt: true): () =>
            context.go('/sales'),
        const SingleActivator(LogicalKeyboardKey.keyP, alt: true): () =>
            context.go('/products'),
        const SingleActivator(LogicalKeyboardKey.keyC, alt: true): () =>
            context.go('/customers'),
        const SingleActivator(LogicalKeyboardKey.keyI, alt: true): () =>
            context.go('/inventory'),
        const SingleActivator(LogicalKeyboardKey.keyH, alt: true): () =>
            context.go('/home'),
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Breakpoint Material 3 Expressive (Large tablets / Desktop)
          final bool isSmallScreen = constraints.maxWidth < 1200;

          if (isSmallScreen) {
            // On mobile, wrap with Scaffold to provide the Drawer.
            // The inner pages have their own Scaffold/AppBar, which will automatically
            // show the generic Menu icon to open this drawer.
            return Scaffold(
              key: MainLayout.scaffoldKey,
              body: widget.child,
              drawer: const SideMenu(isRail: false),
            );
          } else {
            return Scaffold(
              body: SafeArea(
                child: Row(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _isMenuVisible,
                      builder: (context, isVisible, _) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          width: isVisible ? 280 : 72,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border(
                              right: BorderSide(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                                width: 1,
                              ),
                            ),
                          ),
                          child: ClipRect(
                            child: OverflowBox(
                              alignment: Alignment.topLeft,
                              minWidth: isVisible ? 280 : 72,
                              maxWidth: isVisible ? 280 : 72,
                              child: SideMenu(
                                isRail: !isVisible,
                                onToggle: () {
                                  _isMenuVisible.value = !isVisible;
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

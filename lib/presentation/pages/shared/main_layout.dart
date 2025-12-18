import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posventa/presentation/widgets/menu/side_menu.dart';
import 'package:posventa/presentation/widgets/common/theme_toggle_button.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint Material 3 Expressive (Large tablets / Desktop)
        final bool isSmallScreen = constraints.maxWidth < 1200;

        if (isSmallScreen) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: colorScheme.brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: colorScheme.brightness,
            ),
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: Icon(
                      Icons.menu_rounded,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                actions: const [ThemeToggleButton()],
              ),
              drawer: const SideMenu(),
              body: widget.child,
            ),
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
                        width: isVisible ? 280 : 0,
                        child: ClipRect(
                          child: OverflowBox(
                            minWidth: 280,
                            maxWidth: 280,
                            alignment: Alignment.topLeft,
                            child: const RepaintBoundary(child: SideMenu()),
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        // Desktop Header con toggle
                        _DesktopHeader(
                          isMenuVisible: _isMenuVisible,
                          colorScheme: colorScheme,
                        ),
                        Expanded(child: widget.child),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  final ValueNotifier<bool> isMenuVisible;
  final ColorScheme colorScheme;

  const _DesktopHeader({
    required this.isMenuVisible,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface),
            onPressed: () {
              isMenuVisible.value = !isMenuVisible.value;
            },
            tooltip: 'Alternar menú',
          ),
          const Spacer(),
          const ThemeToggleButton(),
        ],
      ),
    );
  }
}

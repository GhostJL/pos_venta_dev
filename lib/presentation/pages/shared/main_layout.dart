import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/auto_backup_provider.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';
import 'package:posventa/presentation/widgets/dialogs/backup_confirmation_dialog.dart';
import 'package:posventa/presentation/widgets/menu/side_menu.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => MainLayoutState();

  static MainLayoutState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainLayoutState>();
  }
}

class MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _lastBackPress;

  bool _isMenuExpanded = false;

  void _toggleMenu() {
    setState(() {
      _isMenuExpanded = !_isMenuExpanded;
    });
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    // Check if this is a double-back (within 2 seconds)
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presiona de nuevo para salir'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }

    // Check backup settings
    final settings = await ref.read(settingsProvider.future);
    if (settings.backupOnAppClose && mounted) {
      // Show backup confirmation dialog
      await showBackupConfirmationDialog(
        context,
        title: 'Salir de la Aplicación',
        message: '¿Deseas crear un backup antes de salir?',
        onBackup: () async {
          final autoBackupService = ref.read(autoBackupServiceProvider);
          return await autoBackupService.executeBackup(settings);
        },
      );
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
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
          // Breakpoint: 900px (Tablet Landscape / Desktop)
          final bool isWideScreen = constraints.maxWidth >= 900;

          if (isWideScreen) {
            return Scaffold(
              body: Row(
                children: [
                  // Collapsible SideMenu
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: _isMenuExpanded ? 280 : 80,
                    child: ClipRect(
                      child: SideMenu(
                        isCollapsed: !_isMenuExpanded,
                        onToggle: _toggleMenu,
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: ClipRect(child: widget.child)),
                ],
              ),
            );
          } else {
            // Mobile / Small Tablet Layout
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
                if (Platform.isAndroid || Platform.isIOS) {
                  final shouldPop = await _onWillPop();
                  if (shouldPop && context.mounted) {
                    SystemNavigator.pop();
                  }
                }
              },
              child: Scaffold(
                key: _scaffoldKey,
                drawer: SideMenu(
                  isCollapsed: false,
                  onToggle: () {
                    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                      _scaffoldKey.currentState?.closeDrawer();
                    }
                  },
                ),
                body: widget.child,
              ),
            );
          }
        },
      ),
    );
  }
}

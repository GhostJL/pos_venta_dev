import 'dart:async';
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
  final ValueNotifier<bool> _isMenuVisible = ValueNotifier<bool>(true);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _lastBackPress;

  @override
  void dispose() {
    _isMenuVisible.dispose();
    super.dispose();
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    // Check if this is a double-back (within 2 seconds)
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      // First back press
      _lastBackPress = now;

      // Show SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presiona de nuevo para salir'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return false; // Don't exit
    }

    // Second back press - check if backup is needed
    final settings = await ref.read(settingsProvider.future);

    if (settings.backupOnAppClose && mounted) {
      // Show backup confirmation dialog
      final shouldBackup = await showBackupConfirmationDialog(
        context,
        title: 'Salir de la Aplicación',
        message: '¿Deseas crear un backup antes de salir?',
        onBackup: () async {
          final autoBackupService = ref.read(autoBackupServiceProvider);
          return await autoBackupService.executeBackup(settings);
        },
      );

      // Exit regardless of backup choice
      return true;
    }

    return true; // Exit
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
            // On mobile, wrap with PopScope for double-back to exit
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;

                // Only handle back on Android/iOS
                if (Platform.isAndroid || Platform.isIOS) {
                  final shouldPop = await _onWillPop();
                  if (shouldPop && context.mounted) {
                    SystemNavigator.pop();
                  }
                }
              },
              child: Scaffold(
                key: _scaffoldKey,
                body: widget.child,
                drawer: const SideMenu(isRail: false),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';

/// A widget that displays a theme toggle button in the AppBar
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return IconButton(
      icon: Icon(
        themeMode == ThemeMode.dark
            ? Icons.light_mode
            : themeMode == ThemeMode.light
            ? Icons.dark_mode
            : Icons.brightness_auto,
      ),
      tooltip: themeMode == ThemeMode.dark
          ? 'Cambiar a modo claro'
          : themeMode == ThemeMode.light
          ? 'Cambiar a modo oscuro'
          : 'Modo automático',
      onPressed: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
    );
  }
}

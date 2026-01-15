import 'package:flutter/material.dart';

class SettingsLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget desktopLayout;

  const SettingsLayout({
    super.key,
    required this.mobileLayout,
    required this.desktopLayout,
  });

  static const int mobileBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileBreakpoint) {
          return mobileLayout;
        } else {
          return desktopLayout;
        }
      },
    );
  }
}

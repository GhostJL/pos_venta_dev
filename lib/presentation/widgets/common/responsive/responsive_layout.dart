import 'package:flutter/material.dart';

/// A widget that builds different layouts depending on the screen size.
///
/// Breakpoints:
/// - Mobile: < 600
/// - Tablet: >= 600 && < 1100
/// - Desktop: >= 1100
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  /// Mobile breakpoint width
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint width
  static const double tabletBreakpoint = 1100;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint) {
          return desktop;
        } else if (constraints.maxWidth >= mobileBreakpoint) {
          return tablet ??
              desktop; // Fallback to desktop if tablet not provided, or mobile? Usually tablet is closer to desktop in structure.
          // However, often tablet is just a constrained desktop.
          // Let's fallback to mobile if tablet is null? No, tablet usually has more space.
          // Let's fallback to desktop but maybe user wants mobile.
          // Actually, standard practice:
          // If tablet is null, use mobile? Or desktop?
          // If tablet is null, it typically means "use mobile layout but stretched" OR "use desktop layout but squeezed".
          // Let's assume if tablet is missing, we use mobile for consistency with 'mobile first',
          // BUT given this is a POS, desktop is primary.
          // Let's default to [mobile] if [tablet] is null, behaving like "Mobile and up" vs "Desktop".
          // Wait, if I have Mobile and Desktop, Tablet usually acts like Mobile (hamburger menu) or Desktop (sidebar)?
          // Let's stick to: if tablet provided, use it. If not, use mobile.
          // Actually, let's use [mobile] as fallback for tablet to ensure safe rendering on smaller tablets if desktop is too wide.
        } else {
          return mobile;
        }
      },
    );
  }
}

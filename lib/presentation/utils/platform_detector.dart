import 'package:flutter/material.dart';

/// Enum representing the different device platforms based on screen width
enum DevicePlatform {
  /// Mobile devices (width < 600px)
  mobile,

  /// Tablet devices (600px <= width < 900px)
  tablet,

  /// Desktop devices (width >= 900px)
  desktop,
}

/// Utility class for detecting the current device platform based on screen size
class PlatformDetector {
  /// Detects the current platform based on the screen width
  ///
  /// Returns:
  /// - [DevicePlatform.mobile] if width < 600
  /// - [DevicePlatform.tablet] if 600 <= width < 900
  /// - [DevicePlatform.desktop] if width >= 900
  static DevicePlatform detect(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return DevicePlatform.mobile;
    } else if (width < 900) {
      return DevicePlatform.tablet;
    } else {
      return DevicePlatform.desktop;
    }
  }

  /// Returns true if the current platform is mobile
  static bool isMobile(BuildContext context) {
    return detect(context) == DevicePlatform.mobile;
  }

  /// Returns true if the current platform is tablet
  static bool isTablet(BuildContext context) {
    return detect(context) == DevicePlatform.tablet;
  }

  /// Returns true if the current platform is desktop
  static bool isDesktop(BuildContext context) {
    return detect(context) == DevicePlatform.desktop;
  }

  /// Returns true if the current platform is mobile or tablet
  static bool isMobileOrTablet(BuildContext context) {
    final platform = detect(context);
    return platform == DevicePlatform.mobile ||
        platform == DevicePlatform.tablet;
  }
}

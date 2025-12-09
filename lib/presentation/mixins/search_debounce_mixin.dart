import 'dart:async';
import 'package:flutter/material.dart';

/// Mixin that provides debounce functionality for search operations.
///
/// This prevents excessive API calls or expensive operations by waiting
/// until the user stops typing before executing the search callback.
///
/// Usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with SearchDebounceMixin {
///   void _onSearchChanged(String value) {
///     debounceSearch(() {
///       // This executes 1 second after user stops typing
///       performSearch(value);
///     });
///   }
/// }
/// ```
mixin SearchDebounceMixin<T extends StatefulWidget> on State<T> {
  Timer? _debounceTimer;

  /// Debounces the execution of [callback] by [duration].
  ///
  /// If called again before [duration] expires, the previous timer is cancelled
  /// and a new one is started. This ensures the callback only executes once
  /// the user has stopped triggering the debounce for [duration].
  ///
  /// [callback] - The function to execute after debounce
  /// [duration] - How long to wait (default: 1 second)
  void debounceSearch(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

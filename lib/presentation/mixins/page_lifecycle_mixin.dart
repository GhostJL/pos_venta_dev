import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A mixin that provides common page lifecycle functionality.
///
/// This mixin handles the common pattern of invalidating providers
/// when a page is first loaded.
///
/// Example usage:
/// ```dart
/// class MyPageState extends ConsumerState<MyPage> with PageLifecycleMixin {
///   @override
///   List<ProviderOrFamily> get providersToInvalidate => [
///     myDataProvider,
///     myOtherProvider,
///   ];
///
///   @override
///   Widget build(BuildContext context) {
///     // Your build method
///   }
/// }
/// ```
mixin PageLifecycleMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// List of providers to invalidate when the page loads
  List<dynamic> get providersToInvalidate;

  @override
  void initState() {
    super.initState();
    _invalidateProviders();
  }

  void _invalidateProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final provider in providersToInvalidate) {
        ref.invalidate(provider);
      }
    });
  }

  /// Manually refresh all providers
  void refreshProviders() {
    _invalidateProviders();
  }
}

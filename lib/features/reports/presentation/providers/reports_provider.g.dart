// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReportsNotifier)
const reportsProvider = ReportsNotifierProvider._();

final class ReportsNotifierProvider
    extends $NotifierProvider<ReportsNotifier, ReportsState> {
  const ReportsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsNotifierHash();

  @$internal
  @override
  ReportsNotifier create() => ReportsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportsState>(value),
    );
  }
}

String _$reportsNotifierHash() => r'94f16bd6fb4fb8e6b8d3863d8bc7751ed5a57fb1';

abstract class _$ReportsNotifier extends $Notifier<ReportsState> {
  ReportsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ReportsState, ReportsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReportsState, ReportsState>,
              ReportsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

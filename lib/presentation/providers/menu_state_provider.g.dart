// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier para gestionar el estado del menú

@ProviderFor(MenuState)
const menuStateProvider = MenuStateProvider._();

/// Notifier para gestionar el estado del menú
final class MenuStateProvider
    extends $NotifierProvider<MenuState, MenuStateData> {
  /// Notifier para gestionar el estado del menú
  const MenuStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'menuStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$menuStateHash();

  @$internal
  @override
  MenuState create() => MenuState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MenuStateData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MenuStateData>(value),
    );
  }
}

String _$menuStateHash() => r'29b9ad160440faeb75fd3a4f69dfb7947188949e';

/// Notifier para gestionar el estado del menú

abstract class _$MenuState extends $Notifier<MenuStateData> {
  MenuStateData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MenuStateData, MenuStateData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MenuStateData, MenuStateData>,
              MenuStateData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

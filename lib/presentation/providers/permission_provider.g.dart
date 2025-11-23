// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentUserPermissions)
const currentUserPermissionsProvider = CurrentUserPermissionsProvider._();

final class CurrentUserPermissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  const CurrentUserPermissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserPermissionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserPermissionsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return currentUserPermissions(ref);
  }
}

String _$currentUserPermissionsHash() =>
    r'0b8a0c23fbe3bb321b6e03809719f6f575c86476';

@ProviderFor(hasPermission)
const hasPermissionProvider = HasPermissionFamily._();

final class HasPermissionProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const HasPermissionProvider._({
    required HasPermissionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hasPermissionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hasPermissionHash();

  @override
  String toString() {
    return r'hasPermissionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return hasPermission(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HasPermissionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasPermissionHash() => r'128d3701965987cfea5400139e2036bfdca08da3';

final class HasPermissionFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  const HasPermissionFamily._()
    : super(
        retry: null,
        name: r'hasPermissionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HasPermissionProvider call(String permissionCode) =>
      HasPermissionProvider._(argument: permissionCode, from: this);

  @override
  String toString() => r'hasPermissionProvider';
}

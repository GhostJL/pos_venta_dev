// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DepartmentList)
const departmentListProvider = DepartmentListProvider._();

final class DepartmentListProvider
    extends $AsyncNotifierProvider<DepartmentList, List<Department>> {
  const DepartmentListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'departmentListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$departmentListHash();

  @$internal
  @override
  DepartmentList create() => DepartmentList();
}

String _$departmentListHash() => r'dd6f484dda4aa69c215bf643bbea8947a8d40e04';

abstract class _$DepartmentList extends $AsyncNotifier<List<Department>> {
  FutureOr<List<Department>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<Department>>, List<Department>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Department>>, List<Department>>,
              AsyncValue<List<Department>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

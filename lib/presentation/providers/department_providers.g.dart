// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(departmentRepository)
const departmentRepositoryProvider = DepartmentRepositoryProvider._();

final class DepartmentRepositoryProvider
    extends
        $FunctionalProvider<
          DepartmentRepository,
          DepartmentRepository,
          DepartmentRepository
        >
    with $Provider<DepartmentRepository> {
  const DepartmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'departmentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$departmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<DepartmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DepartmentRepository create(Ref ref) {
    return departmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DepartmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DepartmentRepository>(value),
    );
  }
}

String _$departmentRepositoryHash() =>
    r'6638a2189d7237fe4ff8c706b31cc31d08de7666';

@ProviderFor(getAllDepartmentsUseCase)
const getAllDepartmentsUseCaseProvider = GetAllDepartmentsUseCaseProvider._();

final class GetAllDepartmentsUseCaseProvider
    extends
        $FunctionalProvider<
          GetAllDepartments,
          GetAllDepartments,
          GetAllDepartments
        >
    with $Provider<GetAllDepartments> {
  const GetAllDepartmentsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllDepartmentsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllDepartmentsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAllDepartments> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetAllDepartments create(Ref ref) {
    return getAllDepartmentsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAllDepartments value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAllDepartments>(value),
    );
  }
}

String _$getAllDepartmentsUseCaseHash() =>
    r'80fa7e9afd4dddc070afc44250baf21059d6762a';

@ProviderFor(createDepartmentUseCase)
const createDepartmentUseCaseProvider = CreateDepartmentUseCaseProvider._();

final class CreateDepartmentUseCaseProvider
    extends
        $FunctionalProvider<
          CreateDepartment,
          CreateDepartment,
          CreateDepartment
        >
    with $Provider<CreateDepartment> {
  const CreateDepartmentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createDepartmentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createDepartmentUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateDepartment> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateDepartment create(Ref ref) {
    return createDepartmentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateDepartment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateDepartment>(value),
    );
  }
}

String _$createDepartmentUseCaseHash() =>
    r'b80b39dfad97d33d851419d6028d9aca861fc058';

@ProviderFor(updateDepartmentUseCase)
const updateDepartmentUseCaseProvider = UpdateDepartmentUseCaseProvider._();

final class UpdateDepartmentUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateDepartment,
          UpdateDepartment,
          UpdateDepartment
        >
    with $Provider<UpdateDepartment> {
  const UpdateDepartmentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateDepartmentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateDepartmentUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateDepartment> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateDepartment create(Ref ref) {
    return updateDepartmentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateDepartment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateDepartment>(value),
    );
  }
}

String _$updateDepartmentUseCaseHash() =>
    r'ff1b33b57341bf002a39e36fd9af06d5e634ebd4';

@ProviderFor(deleteDepartmentUseCase)
const deleteDepartmentUseCaseProvider = DeleteDepartmentUseCaseProvider._();

final class DeleteDepartmentUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteDepartment,
          DeleteDepartment,
          DeleteDepartment
        >
    with $Provider<DeleteDepartment> {
  const DeleteDepartmentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteDepartmentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteDepartmentUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteDepartment> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteDepartment create(Ref ref) {
    return deleteDepartmentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteDepartment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteDepartment>(value),
    );
  }
}

String _$deleteDepartmentUseCaseHash() =>
    r'8adf73912ee6518c070b44a3d9fdfc30b267de2d';

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
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$departmentListHash();

  @$internal
  @override
  DepartmentList create() => DepartmentList();
}

String _$departmentListHash() => r'e9655c8752311fe4a572d6855141a4201f71aef5';

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

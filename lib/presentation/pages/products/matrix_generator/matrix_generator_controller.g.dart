// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matrix_generator_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MatrixGeneratorNotifier)
const matrixGeneratorProvider = MatrixGeneratorNotifierFamily._();

final class MatrixGeneratorNotifierProvider
    extends $NotifierProvider<MatrixGeneratorNotifier, MatrixGeneratorState> {
  const MatrixGeneratorNotifierProvider._({
    required MatrixGeneratorNotifierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'matrixGeneratorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$matrixGeneratorNotifierHash();

  @override
  String toString() {
    return r'matrixGeneratorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MatrixGeneratorNotifier create() => MatrixGeneratorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatrixGeneratorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatrixGeneratorState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MatrixGeneratorNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$matrixGeneratorNotifierHash() =>
    r'd1f178885d9b8a3050030f78f35b5df8cdd49bc0';

final class MatrixGeneratorNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MatrixGeneratorNotifier,
          MatrixGeneratorState,
          MatrixGeneratorState,
          MatrixGeneratorState,
          int
        > {
  const MatrixGeneratorNotifierFamily._()
    : super(
        retry: null,
        name: r'matrixGeneratorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MatrixGeneratorNotifierProvider call(int productId) =>
      MatrixGeneratorNotifierProvider._(argument: productId, from: this);

  @override
  String toString() => r'matrixGeneratorProvider';
}

abstract class _$MatrixGeneratorNotifier
    extends $Notifier<MatrixGeneratorState> {
  late final _$args = ref.$arg as int;
  int get productId => _$args;

  MatrixGeneratorState build(int productId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<MatrixGeneratorState, MatrixGeneratorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MatrixGeneratorState, MatrixGeneratorState>,
              MatrixGeneratorState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

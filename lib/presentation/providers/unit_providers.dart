import 'package:posventa/data/repositories/unit_of_measure_repository_impl.dart';
import 'package:posventa/domain/entities/unit_of_measure.dart';
import 'package:posventa/domain/repositories/unit_of_measure_repository.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unit_providers.g.dart';

@riverpod
UnitOfMeasureRepository unitOfMeasureRepository(ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return UnitOfMeasureRepositoryImpl(dbHelper);
}

@Riverpod(keepAlive: true)
class UnitList extends _$UnitList {
  @override
  Future<List<UnitOfMeasure>> build() async {
    final repo = ref.watch(unitOfMeasureRepositoryProvider);
    return repo.getAllUnits();
  }
}

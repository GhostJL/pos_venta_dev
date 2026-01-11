import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/data/repositories/reports_repository_impl.dart';
import 'package:posventa/domain/repositories/reports_repository.dart';
import 'package:posventa/presentation/providers/di/core_di.dart'; // Assuming appDatabaseProvider is here

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReportsRepositoryImpl(db);
});

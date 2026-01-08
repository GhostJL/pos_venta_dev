import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/domain/services/audit_service.dart';
import 'package:posventa/core/utils/logger.dart';

class AuditServiceImpl implements AuditService {
  final drift_db.AppDatabase db;

  AuditServiceImpl(this.db);

  @override
  Future<void> logAction({
    required String action,
    required String module,
    String? details,
    int? userId,
  }) async {
    try {
      await db
          .into(db.auditLogs)
          .insert(
            drift_db.AuditLogsCompanion.insert(
              action: action,
              module: module,
              details: Value(details),
              userId: Value(userId),
              createdAt: Value(DateTime.now()),
            ),
          );

      appLogger.info('AUDIT: [$module] $action - $details (User: $userId)');
    } catch (e) {
      // If audit fails, we log it to console/file but don't crash core app flow
      appLogger.severe('Failed to write audit log', e);
    }
  }
}

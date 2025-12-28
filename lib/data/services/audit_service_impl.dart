import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/domain/services/audit_service.dart';
import 'package:posventa/core/utils/logger.dart';

class AuditServiceImpl implements AuditService {
  final DatabaseHelper databaseHelper;

  AuditServiceImpl(this.databaseHelper);

  @override
  Future<void> logAction({
    required String action,
    required String module,
    String? details,
    int? userId,
  }) async {
    try {
      final db = await databaseHelper.database;

      await db.insert(DatabaseHelper.tableAuditLogs, {
        'user_id': userId,
        'action': action,
        'module': module,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
      });

      appLogger.info('AUDIT: [$module] $action - $details (User: $userId)');
    } catch (e) {
      // If audit fails, we log it to console/file but don't crash core app flow
      appLogger.severe('Failed to write audit log', e);
    }
  }
}

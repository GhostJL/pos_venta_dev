abstract class AuditService {
  Future<void> logAction({
    required String action,
    required String module,
    String? details,
    int? userId,
  });
}

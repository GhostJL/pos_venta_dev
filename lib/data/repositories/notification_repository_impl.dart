import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/domain/entities/notification.dart';
import 'package:posventa/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final drift_db.AppDatabase db;

  NotificationRepositoryImpl(this.db);

  @override
  Future<List<AppNotification>> getNotifications() async {
    final query = db.select(db.notifications)
      ..orderBy([
        (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
      ]);
    final rows = await query.get();
    return rows.map(_mapToNotification).toList();
  }

  @override
  Future<List<AppNotification>> getUnreadNotifications() async {
    final query = db.select(db.notifications)
      ..where((t) => t.isRead.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
      ]);
    final rows = await query.get();
    return rows.map(_mapToNotification).toList();
  }

  @override
  Future<void> createNotification(AppNotification notification) async {
    await db
        .into(db.notifications)
        .insert(
          drift_db.NotificationsCompanion.insert(
            title: notification.title,
            body: notification.body,
            timestamp: notification.timestamp,
            isRead: Value(notification.isRead),
            type: notification.type,
            relatedProductId: Value(notification.relatedProductId),
            relatedVariantId: Value(notification.relatedVariantId),
          ),
        );
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await (db.update(db.notifications)
          ..where((t) => t.id.equals(notificationId)))
        .write(const drift_db.NotificationsCompanion(isRead: Value(true)));
  }

  @override
  Future<void> markAllAsRead() async {
    await (db.update(db.notifications)..where((t) => t.isRead.equals(false)))
        .write(const drift_db.NotificationsCompanion(isRead: Value(true)));
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    await (db.delete(
      db.notifications,
    )..where((t) => t.id.equals(notificationId))).go();
  }

  @override
  Future<void> clearAllNotifications() async {
    await db.delete(db.notifications).go();
  }

  @override
  Stream<List<AppNotification>> getNotificationsStream() {
    final query = db.select(db.notifications)
      ..orderBy([
        (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(_mapToNotification).toList());
  }

  AppNotification _mapToNotification(drift_db.Notification row) {
    return AppNotification(
      id: row.id,
      title: row.title,
      body: row.body,
      timestamp: row.timestamp,
      isRead: row.isRead,
      type: row.type,
      relatedProductId: row.relatedProductId,
      relatedVariantId: row.relatedVariantId,
    );
  }
}

import 'package:posventa/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<List<AppNotification>> getUnreadNotifications();
  Future<void> createNotification(AppNotification notification);
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(int notificationId);
  Future<void> clearAllNotifications();
  Stream<List<AppNotification>> getNotificationsStream();
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:posventa/application/services/notification_service.dart';
import 'package:posventa/data/repositories/notification_repository_impl.dart';
import 'package:posventa/domain/entities/notification.dart';
import 'package:posventa/domain/repositories/notification_repository.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepositoryImpl(ref.watch(appDatabaseProvider));
}

@riverpod
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin(Ref ref) {
  return FlutterLocalNotificationsPlugin();
}

@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService(
    ref.watch(notificationRepositoryProvider),
    ref.watch(flutterLocalNotificationsPluginProvider),
  );
}

@riverpod
Stream<List<AppNotification>> notificationsStream(Ref ref) {
  return ref.watch(notificationRepositoryProvider).getNotificationsStream();
}

@riverpod
Stream<List<AppNotification>> unreadNotificationsStream(Ref ref) {
  return ref
      .watch(notificationRepositoryProvider)
      .getNotificationsStream()
      .map((list) => list.where((n) => !n.isRead).toList());
}

@riverpod
Future<void> markNotificationAsRead(Ref ref, int id) async {
  await ref.watch(notificationRepositoryProvider).markAsRead(id);
}

@riverpod
Future<void> markAllNotificationsAsRead(Ref ref) async {
  await ref.watch(notificationRepositoryProvider).markAllAsRead();
}

@riverpod
Future<void> clearAllNotifications(Ref ref) async {
  await ref.watch(notificationRepositoryProvider).clearAllNotifications();
}

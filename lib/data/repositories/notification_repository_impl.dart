import 'package:posventa/data/datasources/database_constants.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/domain/entities/notification.dart';
import 'package:posventa/domain/repositories/notification_repository.dart';
import 'package:sqflite/sqflite.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final DatabaseHelper _dbHelper;

  NotificationRepositoryImpl(this._dbHelper);

  @override
  Future<List<AppNotification>> getNotifications() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableNotifications,
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<List<AppNotification>> getUnreadNotifications() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseConstants.tableNotifications,
      where: 'is_read = 0',
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<void> createNotification(AppNotification notification) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseConstants.tableNotifications,
      _toMap(notification),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _notifyChanges();
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseConstants.tableNotifications,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
    _notifyChanges();
  }

  @override
  Future<void> markAllAsRead() async {
    final db = await _dbHelper.database;
    await db.update(DatabaseConstants.tableNotifications, {
      'is_read': 1,
    }, where: 'is_read = 0');
    _notifyChanges();
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseConstants.tableNotifications,
      where: 'id = ?',
      whereArgs: [notificationId],
    );
    _notifyChanges();
  }

  @override
  Future<void> clearAllNotifications() async {
    final db = await _dbHelper.database;
    await db.delete(DatabaseConstants.tableNotifications);
    _notifyChanges();
  }

  @override
  Stream<List<AppNotification>> getNotificationsStream() async* {
    yield await getNotifications();
    await for (final table in _dbHelper.tableUpdateStream) {
      if (table == DatabaseConstants.tableNotifications) {
        yield await getNotifications();
      }
    }
  }

  void _notifyChanges() {
    _dbHelper.notifyTableChanged(DatabaseConstants.tableNotifications);
  }

  AppNotification _fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as int?,
      title: map['title'] as String,
      body: map['body'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: (map['is_read'] as int) == 1,
      type: map['type'] as String,
      relatedProductId: map['related_product_id'] as int?,
      relatedVariantId: map['related_variant_id'] as int?,
    );
  }

  Map<String, dynamic> _toMap(AppNotification notification) {
    return {
      if (notification.id != null) 'id': notification.id,
      'title': notification.title,
      'body': notification.body,
      'timestamp': notification.timestamp.toIso8601String(),
      'is_read': notification.isRead ? 1 : 0,
      'type': notification.type,
      'related_product_id': notification.relatedProductId,
      'related_variant_id': notification.relatedVariantId,
    };
  }
}

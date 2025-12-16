import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:posventa/domain/entities/notification.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  NotificationService(this._repository, this._localNotificationsPlugin) {
    _initializeLocalNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    try {
      await _localNotificationsPlugin.initialize(
        initializationSettings,
        // onDidReceiveNotificationResponse: ... (Handle tap if needed)
      );
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      final granted = await androidImplementation
          .requestNotificationsPermission();
    }
  }

  Future<void> checkStockLevel({
    required ProductVariant variant,
    required String productName,
    required double currentStock,
  }) async {
    // Logic:
    // 1. If stock <= 0: Out of stock
    // 2. If stock <= minStock: Low stock
    // 3. Debounce/Check if notification already sent recently? (For now, simple implementation)

    String? title;
    String? body;
    String? type;

    if (currentStock <= 0) {
      title = 'Sin Stock: $productName';
      body = 'El producto $productName (${variant.variantName}) se ha agotado.';
      type = 'out_of_stock';
    } else if (variant.stockMin != null && currentStock <= variant.stockMin!) {
      title = 'Stock Bajo: $productName';
      body =
          'Quedan $currentStock unidades de $productName (${variant.variantName}).';
      type = 'low_stock';
    }

    if (title != null && body != null && type != null) {
      // Create App Notification
      final notification = AppNotification(
        title: title,
        body: body,
        timestamp: DateTime.now(),
        isRead: false,
        type: type,
        relatedProductId: variant.productId,
        relatedVariantId: variant.id,
      );

      await _repository.createNotification(notification);

      // Send Local Notification
      await _showLocalNotification(
        id: variant.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
      );
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'inventory_alerts',
      'Inventory Alerts',
      channelDescription: 'Notifications for low stock and out of stock items',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(id, title, body, details);
  }
}

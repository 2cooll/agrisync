import '../models/notification_model.dart';
import '../mock_data.dart';
import 'local_storage_service.dart';

abstract class INotificationService {
  List<NotificationModel> getNotifications();
  void addNotification(NotificationModel notification);
  void markAsRead(String notificationId);
  void markAllAsRead(String userId);
}

class MockNotificationService implements INotificationService {
  final LocalStorageService? _storage;
  late List<NotificationModel> _notifications;

  MockNotificationService({LocalStorageService? storage, List<NotificationModel>? initialNotifications})
      : _storage = storage {
    _notifications = initialNotifications ?? (_storage?.loadNotifications() ?? MockData.getInitialNotifications());
  }

  @override
  List<NotificationModel> getNotifications() => List.unmodifiable(_notifications);

  @override
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _storage?.saveNotifications(_notifications);
  }

  @override
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _storage?.saveNotifications(_notifications);
    }
  }

  @override
  void markAllAsRead(String userId) {
    _notifications = _notifications.map((n) {
      if (n.recipientUserId == userId || n.recipientUserId == 'all') {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    _storage?.saveNotifications(_notifications);
  }
}

import '../models/notification_model.dart';
import '../services/notification_service.dart';

abstract class NotificationRepository {
  List<NotificationModel> getNotifications();
  List<NotificationModel> getNotificationsForUser(String userId);
  int getUnreadCount(String userId);
  void addNotification(NotificationModel notification);
  void markAsRead(String notificationId);
  void markAllAsRead(String userId);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final INotificationService _notificationService;

  NotificationRepositoryImpl({INotificationService? notificationService})
      : _notificationService = notificationService ?? MockNotificationService();

  @override
  List<NotificationModel> getNotifications() => _notificationService.getNotifications();

  @override
  List<NotificationModel> getNotificationsForUser(String userId) {
    return _notificationService
        .getNotifications()
        .where((n) => n.recipientUserId == userId || n.recipientUserId == 'all')
        .toList();
  }

  @override
  int getUnreadCount(String userId) {
    return getNotificationsForUser(userId).where((n) => !n.isRead).length;
  }

  @override
  void addNotification(NotificationModel notification) {
    _notificationService.addNotification(notification);
  }

  @override
  void markAsRead(String notificationId) {
    _notificationService.markAsRead(notificationId);
  }

  @override
  void markAllAsRead(String userId) {
    _notificationService.markAllAsRead(userId);
  }
}

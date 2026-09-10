import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationPermissionStatus {
  granted,
  denied,
  defaultStatus,
  unsupported,
}

class SystemNotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static const String channelId = 'agrisync_notifications';
  static const String channelName = 'Pemberitahuan AgriSync';
  static const String channelDescription =
      'Saluran push notifikasi instan untuk pesanan, penawaran harga, dan pembaruan hasil panen AgriSync.';

  static Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const linuxInit = LinuxInitializationSettings(defaultActionName: 'Open notification');

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
        linux: linuxInit,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('🔔 [SystemNotificationHelper] Notification tapped: ${response.payload}');
        },
      );

      // Create Android Notification Channel
      try {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          const androidChannel = AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
          );
          await androidImplementation.createNotificationChannel(androidChannel);
        }
      } catch (_) {}

      _isInitialized = true;
      debugPrint('✅ [SystemNotificationHelper] flutter_local_notifications initialized successfully.');
    } catch (e) {
      debugPrint('ℹ️ [SystemNotificationHelper] Init notice: $e');
    }
  }

  static Future<NotificationPermissionStatus> getPermissionStatus() async {
    if (kIsWeb) return NotificationPermissionStatus.granted;
    try {
      await ensureInitialized();
      try {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final areNotificationsEnabled = await androidImplementation.areNotificationsEnabled();
          if (areNotificationsEnabled == true) {
            return NotificationPermissionStatus.granted;
          } else if (areNotificationsEnabled == false) {
            return NotificationPermissionStatus.denied;
          }
        }
      } catch (_) {}
      return NotificationPermissionStatus.granted;
    } catch (e) {
      return NotificationPermissionStatus.granted;
    }
  }

  static Future<NotificationPermissionStatus> requestPermission() async {
    if (kIsWeb) return NotificationPermissionStatus.granted;
    try {
      await ensureInitialized();
      try {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final granted = await androidImplementation.requestNotificationsPermission();
          if (granted == true) {
            return NotificationPermissionStatus.granted;
          } else if (granted == false) {
            return NotificationPermissionStatus.denied;
          }
        }
      } catch (_) {}

      try {
        final iosImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (iosImplementation != null) {
          final granted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return granted == true
              ? NotificationPermissionStatus.granted
              : NotificationPermissionStatus.denied;
        }
      } catch (_) {}

      return NotificationPermissionStatus.granted;
    } catch (e) {
      debugPrint('ℹ️ [SystemNotificationHelper] Request permission notice: $e');
      return NotificationPermissionStatus.granted;
    }
  }

  static Future<bool> showSystemNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
  }) async {
    try {
      await ensureInitialized();

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      final id = (tag != null
              ? tag.hashCode
              : DateTime.now().millisecondsSinceEpoch.remainder(100000))
          .abs();
      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: tag,
      );
      return true;
    } catch (e) {
      debugPrint('ℹ️ [SystemNotificationHelper] Notice: $e');
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/notification_model.dart';
import '../../state/app_state.dart';
import '../../ui/widgets/agri_push_banner.dart';
import '../../ui/screens/orders/order_tracking_screen.dart';
import '../../ui/screens/orders/order_history_screen.dart';
import '../../ui/screens/chat/chat_negotiation_screen.dart';
import 'system_notification_helper.dart';

class PushNotificationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Cek status izin notifikasi sistem / browser
  static Future<NotificationPermissionStatus> getPermissionStatus() {
    return SystemNotificationHelper.getPermissionStatus();
  }

  /// Minta izin notifikasi langsung ke sistem / browser OS
  static Future<NotificationPermissionStatus> requestPermission() {
    return SystemNotificationHelper.requestPermission();
  }

  /// Tampilkan push notification banner jika kategori notifikasi diaktifkan pengguna di pengaturan
  static bool showPushIfEnabled(NotificationModel notification, AppState appState, {BuildContext? customContext}) {
    final settings = appState.notificationSettings;
    bool isEnabled = true;

    switch (notification.type) {
      case NotificationType.order:
        isEnabled = settings['orders'] ?? true;
        break;
      case NotificationType.negotiation:
      case NotificationType.chat:
        isEnabled = settings['negotiations'] ?? true;
        break;
      case NotificationType.harvest:
        isEnabled = settings['harvests'] ?? true;
        break;
      case NotificationType.priceTrend:
        isEnabled = settings['price_trends'] ?? true;
        break;
      case NotificationType.promotion:
        isEnabled = settings['promotions'] ?? false;
        break;
      case NotificationType.system:
        isEnabled = true;
        break;
    }

    if (!isEnabled) {
      debugPrint('ℹ️ [PushNotificationService] Push notification suppressed by user preference: ${notification.type.name}');
      return false;
    }

    BuildContext? context = customContext;
    if (context == null) {
      try {
        context = navigatorKey.currentContext;
      } catch (_) {
        context = null;
      }
    }
    if (context == null) return false;

    final targetContext = context;

    // Trigger haptic vibration if sound_vibrate is enabled
    final soundVibrate = settings['sound_vibrate'] ?? true;
    if (soundVibrate) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }

    AgriPushBanner.show(
      targetContext,
      notification: notification,
      onTap: () => _handleNotificationTap(targetContext, notification, appState),
    );

    // Also dispatch OS/browser level system notification toast
    SystemNotificationHelper.showSystemNotification(
      title: notification.title,
      body: notification.message,
      icon: 'icons/Icon-192.png',
      tag: notification.id,
    );

    return true;
  }

  /// Navigasi cerdas saat push notification banner diklik
  static void _handleNotificationTap(BuildContext context, NotificationModel notification, AppState appState) {
    appState.markNotificationAsRead(notification.id);

    if (notification.type == NotificationType.order) {
      if (notification.referenceId != null) {
        final matching = appState.orders.where((o) => o.id == notification.referenceId);
        if (matching.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(order: matching.first),
            ),
          );
          return;
        }
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
      );
    } else if (notification.type == NotificationType.negotiation || notification.type == NotificationType.chat) {
      if (notification.referenceId != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatNegotiationScreen(threadId: notification.referenceId!),
          ),
        );
      }
    }
  }

  /// Simulasi kirim notifikasi uji coba per kategori preferensi pengguna
  static bool sendTestNotification(
    AppState appState, {
    required String categoryKey,
    BuildContext? context,
  }) {
    final now = DateTime.now();
    late final NotificationModel sampleNotif;

    switch (categoryKey) {
      case 'orders':
        sampleNotif = NotificationModel(
          id: 'test_order_${now.millisecondsSinceEpoch}',
          recipientUserId: appState.currentUser.id,
          senderName: 'Sistem Escrow AgriSync',
          title: '📦 Update Status: Pembayaran Escrow Diverifikasi',
          message: 'Dana pembayaran pesanan Cabai Rawit Merah (100 kg) aman tersimpan di Rekber Escrow AgriSync.',
          type: NotificationType.order,
          createdAt: now,
        );
        break;

      case 'negotiations':
        sampleNotif = NotificationModel(
          id: 'test_nego_${now.millisecondsSinceEpoch}',
          recipientUserId: appState.currentUser.id,
          senderName: 'Pak Subagyo (Petani)',
          title: '💬 Tawaran Negosiasi Baru Diterima',
          message: 'Pak Subagyo mengajukan harga penawaran Rp 29.500/kg untuk Tomat Cherry Super.',
          type: NotificationType.negotiation,
          createdAt: now,
        );
        break;

      case 'harvests':
        sampleNotif = NotificationModel(
          id: 'test_harvest_${now.millisecondsSinceEpoch}',
          recipientUserId: appState.currentUser.id,
          senderName: 'Jadwal Panen AgriSync',
          title: '🌾 Pengingat Jadwal Panen Raya',
          message: 'Panen Kentang Granola Bromo (Lahan A) siap dipetik dalam 3 hari ke depan.',
          type: NotificationType.harvest,
          createdAt: now,
        );
        break;

      case 'price_trends':
        sampleNotif = NotificationModel(
          id: 'test_price_${now.millisecondsSinceEpoch}',
          recipientUserId: appState.currentUser.id,
          senderName: 'Sinyal Pasar AgriSync',
          title: '📈 Tren Harga: Cabai Merah Naik 14%',
          message: 'Harga cabai merah di Pasar Induk Malang naik menjadi Rp 42.000/kg karena permintaan tinggi.',
          type: NotificationType.priceTrend,
          createdAt: now,
        );
        break;

      case 'promotions':
        sampleNotif = NotificationModel(
          id: 'test_promo_${now.millisecondsSinceEpoch}',
          recipientUserId: appState.currentUser.id,
          senderName: 'Promo Panen AgriSync',
          title: '🎉 Diskon Komisi Platform 50%!',
          message: 'Gunakan kode PANENRAYA untuk potongan biaya layanan transaksi escrow akhir pekan ini.',
          type: NotificationType.promotion,
          createdAt: now,
        );
        break;

      default:
        sampleNotif = NotificationModel(
          id: 'test_sys_${now.millisecondsSinceEpoch}',
          recipientUserId: appState.currentUser.id,
          senderName: 'Admin AgriSync',
          title: '🔔 Uji Coba Push Notifikasi',
          message: 'Sistem push notifikasi AgriSync aktif dan terhubung ke perangkat Anda.',
          type: NotificationType.system,
          createdAt: now,
        );
    }

    // Save to AppState notification list & Cloud Firestore
    appState.addNotification(sampleNotif);

    // Trigger visual push banner if enabled
    return showPushIfEnabled(sampleNotif, appState, customContext: context);
  }
}

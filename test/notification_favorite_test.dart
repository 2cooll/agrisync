import 'package:flutter_test/flutter_test.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/data/models/order_model.dart';
import 'package:agrisync/data/models/notification_model.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Notification & Favorite Feature Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    test('Creating an order generates notifications for both farmer and buyer', () {
      final initialNotifsCount = appState.notifications.length;
      final product = appState.products.first;

      final order = appState.createOrder(
        product: product,
        quantityKg: 50,
        agreedPricePerKg: product.pricePerKg,
        deliveryAddress: 'Jl. Test No. 123',
        paymentMethod: 'Rekber AgriSync',
      );

      expect(order, isNotNull);
      expect(appState.notifications.length, equals(initialNotifsCount + 2));

      // Buyer (Pebisnis) should receive order notification
      final buyerNotifs = appState.currentUserNotifications;
      expect(buyerNotifs.any((n) => n.title.contains('Pesanan Berhasil Dibuat')), isTrue);

      // Farmer (Petani) should receive new order notification
      appState.switchUserRole(UserRole.petani);
      final farmerNotifs = appState.currentUserNotifications;
      expect(farmerNotifs.any((n) => n.title.contains('Pesanan Baru Masuk')), isTrue);
    });

    test('Updating order status sends notification to counterparty', () {
      final order = appState.orders.first;
      appState.switchUserRole(UserRole.petani);

      final countBefore = appState.notifications.length;
      appState.updateOrderStatus(order.id, OrderStatus.dikirim);

      expect(appState.notifications.length, equals(countBefore + 1));
      final latestNotif = appState.notifications.first;
      expect(latestNotif.recipientUserId, equals(order.businessId));
      expect(latestNotif.message, contains('Dalam Pengiriman'));
    });

    test('Favorites toggling and retrieval works accurately', () {
      final product = appState.products.first;
      
      // Ensure product is favorited or toggle it
      final initialFavStatus = appState.isFavorite(product.id);
      appState.toggleFavorite(product.id);
      expect(appState.isFavorite(product.id), equals(!initialFavStatus));

      appState.toggleFavorite(product.id);
      expect(appState.isFavorite(product.id), equals(initialFavStatus));
    });

    test('Marking notifications as read updates unread counter', () {
      appState.switchUserRole(UserRole.pebisnis);
      appState.addNotification(
        NotificationModel(
          id: 'test_notif_1',
          recipientUserId: appState.currentUser.id,
          title: 'Test Notification',
          message: 'Test message body',
          type: NotificationType.system,
          createdAt: DateTime.now(),
          isRead: false,
        ),
      );

      final unreadBefore = appState.unreadNotificationCount;
      expect(unreadBefore, greaterThan(0));

      appState.markNotificationAsRead('test_notif_1');
      expect(appState.unreadNotificationCount, equals(unreadBefore - 1));

      appState.markAllNotificationsAsRead();
      expect(appState.unreadNotificationCount, equals(0));
    });

    test('PushNotificationService sends category notifications respecting user toggle preferences', () {
      appState.switchUserRole(UserRole.pebisnis);

      // 1. Orders notification (Enabled by default)
      expect(appState.notificationSettings['orders'], isTrue);
      final notifOrder = NotificationModel(
        id: 'push_order_1',
        recipientUserId: appState.currentUser.id,
        title: 'Order Status Updated',
        message: 'Order 123 is on delivery',
        type: NotificationType.order,
        createdAt: DateTime.now(),
      );
      appState.addNotification(notifOrder);
      expect(appState.currentUserNotifications.first.id, 'push_order_1');

      // 2. Promotions notification disabled by default
      appState.setNotificationSetting('promotions', false);
      expect(appState.notificationSettings['promotions'], isFalse);

      // 3. Test sending test notifications per category
      final notifHarvest = NotificationModel(
        id: 'push_harvest_1',
        recipientUserId: appState.currentUser.id,
        title: 'Harvest Ready',
        message: 'Potatoes ready to pick',
        type: NotificationType.harvest,
        createdAt: DateTime.now(),
      );
      appState.addNotification(notifHarvest);
      expect(appState.currentUserNotifications.any((n) => n.type == NotificationType.harvest), isTrue);

      final notifPrice = NotificationModel(
        id: 'push_price_1',
        recipientUserId: appState.currentUser.id,
        title: 'Price Trend',
        message: 'Chili price up 10%',
        type: NotificationType.priceTrend,
        createdAt: DateTime.now(),
      );
      appState.addNotification(notifPrice);
      expect(appState.currentUserNotifications.any((n) => n.type == NotificationType.priceTrend), isTrue);
    });

    test('NotificationModel correctly maps to separated categories (Orders/Payments vs Promos/News vs System)', () {
      final orderNotif = NotificationModel(
        id: 'n1',
        recipientUserId: 'u1',
        title: 'Pesanan Masuk',
        message: 'Order baru',
        type: NotificationType.order,
        createdAt: DateTime.now(),
      );
      expect(orderNotif.category, equals(NotificationCategory.ordersPayments));
      expect(orderNotif.categoryLabel, equals('Pesanan & Bayar'));

      final negoNotif = NotificationModel(
        id: 'n2',
        recipientUserId: 'u1',
        title: 'Tawaran Harga',
        message: 'Negosiasi',
        type: NotificationType.negotiation,
        createdAt: DateTime.now(),
      );
      expect(negoNotif.category, equals(NotificationCategory.ordersPayments));

      final promoNotif = NotificationModel(
        id: 'n3',
        recipientUserId: 'u1',
        title: 'Diskon Komisi',
        message: 'Potongan biaya',
        type: NotificationType.promotion,
        createdAt: DateTime.now(),
      );
      expect(promoNotif.category, equals(NotificationCategory.promosNews));
      expect(promoNotif.categoryLabel, equals('Promo & Berita'));

      final priceNotif = NotificationModel(
        id: 'n4',
        recipientUserId: 'u1',
        title: 'Info Pasar',
        message: 'Harga cabai',
        type: NotificationType.priceTrend,
        createdAt: DateTime.now(),
      );
      expect(priceNotif.category, equals(NotificationCategory.promosNews));

      final harvestNotif = NotificationModel(
        id: 'n5',
        recipientUserId: 'u1',
        title: 'Panen Siap',
        message: 'Jadwal panen',
        type: NotificationType.harvest,
        createdAt: DateTime.now(),
      );
      expect(harvestNotif.category, equals(NotificationCategory.promosNews));

      final sysNotif = NotificationModel(
        id: 'n6',
        recipientUserId: 'u1',
        title: 'Verifikasi Berkas',
        message: 'Akun terverifikasi',
        type: NotificationType.system,
        createdAt: DateTime.now(),
      );
      expect(sysNotif.category, equals(NotificationCategory.systemInfo));
      expect(sysNotif.categoryLabel, equals('Info Sistem'));
    });
  });
}

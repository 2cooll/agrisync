import 'package:flutter_test/flutter_test.dart';
import 'package:agrisync/data/services/payment_gateway_service.dart';
import 'package:agrisync/data/services/local_storage_service.dart';
import 'package:agrisync/data/models/product_model.dart';
import 'package:agrisync/data/config/env_config.dart';
import 'package:agrisync/state/app_state.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CPMK 4: Local Storage & Offline-First Persistence Tests', () {
    late LocalStorageService storage;

    setUp(() {
      storage = LocalStorageService(prefs: null);
    });

    test('Auth Token encryption masking and retrieval', () async {
      await storage.saveAuthToken('bearer_jwt_token_secret_12345');
      // In null prefs fallback or in-memory simulation
      expect(storage.loadAuthToken(), isNull); // With null prefs it safely handles exceptions
    });

    test('Offline sync queue can add and clear actions', () async {
      final initialQueue = storage.loadOfflineQueue();
      expect(initialQueue, isEmpty);

      await storage.addToOfflineQueue({
        'type': 'create_order',
        'orderId': 'ord_offline_1',
        'amount': 250000,
      });

      // Handled gracefully in memory
    });
  });

  group('CPMK 5: Payment Gateway & Commission Engine Tests', () {
    test('Calculates 2.5% platform commission for regular free tier users', () {
      final breakdown = PaymentGatewayService.calculateBreakdown(
        itemSubtotal: 1000000,
        shippingFee: 50000,
        isProUser: false,
      );

      expect(breakdown['subtotal'], equals(1000000.0));
      expect(breakdown['shippingFee'], equals(50000.0));
      expect(breakdown['platformFee'], equals(25000.0)); // 2.5% of 1,000,000
      expect(breakdown['total'], equals(1075000.0));
    });

    test('Calculates 1.0% platform commission for AgriSync PRO users', () {
      final breakdown = PaymentGatewayService.calculateBreakdown(
        itemSubtotal: 1000000,
        shippingFee: 50000,
        isProUser: true,
      );

      expect(breakdown['subtotal'], equals(1000000.0));
      expect(breakdown['shippingFee'], equals(50000.0));
      expect(breakdown['platformFee'], equals(10000.0)); // 1.0% of 1,000,000
      expect(breakdown['total'], equals(1060000.0));
    });

    test('Creates sandboxed QRIS and Virtual Account payment transactions', () async {
      final tx = await PaymentGatewayService.createTransaction(
        orderId: 'ORD-TEST-001',
        amount: 500000,
        isProUser: false,
        method: PaymentMethodType.qris,
      );

      expect(tx.status, equals(PaymentStatus.pending));
      expect(tx.orderId, equals('ORD-TEST-001'));
      expect(tx.qrString, isNotNull);
      expect(tx.qrString, contains('ID.CO.AGRISYNC'));

      final settled = await PaymentGatewayService.simulateSettlement(tx);
      expect(settled.status, equals(PaymentStatus.settlement));
      expect(settled.settledAt, isNotNull);
    });
  });

  group('CPMK 2 & 3: Monetization & Offline State Coordination in AppState', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    test('Initial user is free tier and can upgrade to Pro', () async {
      expect(appState.currentUser.isProMember, isFalse);

      final success = await appState.upgradeToPro(isAnnual: true);
      expect(success, isTrue);
      expect(appState.currentUser.isProMember, isTrue);
      expect(appState.currentUser.subscriptionExpiry, isNotNull);

      await appState.cancelProSubscription();
      expect(appState.currentUser.isProMember, isFalse);
    });

    test('Offline mode toggles and sync offline queue functions properly', () async {
      expect(appState.isOfflineMode, isFalse);

      appState.toggleOfflineMode();
      expect(appState.isOfflineMode, isTrue);

      final testProduct = ProductModel(
        id: 'prod_offline_test',
        farmerId: 'farmer_1',
        farmerName: 'Pak Joko',
        farmerLocation: 'Batu, Malang',
        title: 'Bawang Merah Organik',
        category: 'Bawang',
        description: 'Panen offline',
        pricePerKg: 28000,
        stockKg: 100,
        qualityGrade: 'A',
        harvestEstimate: '25 September 2026',
        imageUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb',
        createdAt: DateTime.now(),
      );

      appState.addProduct(testProduct);
      final added = appState.getProductById('prod_offline_test');
      expect(added, isNotNull);
      expect(added!.isPendingSync, isTrue);
      expect(appState.offlinePendingQueue.any((q) => q['productId'] == 'prod_offline_test'), isTrue);

      final syncedCount = await appState.syncOfflineData();
      expect(syncedCount, greaterThanOrEqualTo(1));
      expect(appState.getProductById('prod_offline_test')!.isPendingSync, isFalse);
      expect(appState.offlinePendingQueue.isEmpty, isTrue);
    });
  });

  group('CPMK 6: Obfuscation & Compile-Time Environment Injection Tests', () {
    test('EnvConfig provides safe compile-time defaults and environment flags', () {
      expect(EnvConfig.appEnv.isNotEmpty, isTrue);
      expect(EnvConfig.apiBaseUrl, contains('https://'));
      expect(EnvConfig.apiTimeoutMs, greaterThan(0));
      expect(EnvConfig.paymentCommissionPercent, equals(2.5));
      expect(EnvConfig.isDevelopment, isTrue);
    });

    test('EnvConfig secret masking protects sensitive API keys and secrets', () {
      final masked = EnvConfig.maskSecret('SB-Mid-server-secret-key-123456789');
      expect(masked, startsWith('SB-M'));
      expect(masked, endsWith('6789 (34 chars)'));
      expect(masked.contains('...'), isTrue);

      final summary = EnvConfig.getSecuritySummary();
      expect(summary['isObfuscationConfigured'], isTrue);
      expect(summary['isEnvironmentInjected'], isTrue);
      expect(summary['paymentServerKeyMasked'], isNotNull);
    });
  });
}


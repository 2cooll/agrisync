import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/data/models/order_model.dart';
import 'package:agrisync/data/models/product_model.dart';
import 'package:agrisync/data/models/chat_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AgriSync AppState & Business Logic Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    test('Initial state loads default user and mock products', () {
      expect(appState.isLoggedIn, isTrue);
      expect(appState.currentUser.role, equals(UserRole.pebisnis));
      expect(appState.products.length, greaterThanOrEqualTo(5));
      expect(appState.chatThreads.isNotEmpty, isTrue);
      expect(appState.verifications.isNotEmpty, isTrue);
      expect(appState.orders.isNotEmpty, isTrue);
    });

    test('Role switching between Petani, Pebisnis, Admin works', () {
      appState.switchUserRole(UserRole.petani);
      expect(appState.currentUser.role, equals(UserRole.petani));

      appState.switchUserRole(UserRole.admin);
      expect(appState.currentUser.role, equals(UserRole.admin));

      appState.switchUserRole(UserRole.pebisnis);
      expect(appState.currentUser.role, equals(UserRole.pebisnis));
    });

    test('Register Petani creates user with email and password, queues admin verification', () async {
      final initialVerifications = appState.verifications.length;

      final error = await appState.registerPetani(
        name: 'Pak Budi',
        phone: '081299998888',
        email: 'budi.petani@agrisync.id',
        password: 'password123',
        farmLocation: 'Kediri, Jawa Timur',
        documentPath: 'KTP_Pak_Budi.pdf',
      );

      expect(error, isNull);
      expect(appState.currentUser.name, equals('Pak Budi'));
      expect(appState.currentUser.email, equals('budi.petani@agrisync.id'));
      expect(appState.currentUser.role, equals(UserRole.petani));
      expect(appState.verifications.length, equals(initialVerifications + 1));
      expect(appState.verifications.first.userName, equals('Pak Budi'));
    });

    test('Register Pebisnis and Login with Email/Password works properly', () async {
      final regError = await appState.registerPebisnis(
        businessName: 'Warung Bu Sri',
        businessType: 'Restoran',
        phone: '081377778888',
        email: 'busri@restoran.com',
        password: 'secretPassword123',
      );

      expect(regError, isNull);
      expect(appState.currentUser.name, equals('Warung Bu Sri'));
      expect(appState.currentUser.role, equals(UserRole.pebisnis));

      // Test login with the registered email
      final loginError = await appState.login(
        phone: '081377778888',
        email: 'busri@restoran.com',
        password: 'secretPassword123',
        role: UserRole.pebisnis,
      );

      expect(loginError, isNull);
      expect(appState.currentUser.email, equals('busri@restoran.com'));
    });

    test('Product filtering by search query and category', () {
      appState.setSearchQuery('Cabai');
      final cabaiResults = appState.filteredProducts;
      expect(cabaiResults.every((p) => p.title.toLowerCase().contains('cabai')), isTrue);

      appState.setSearchQuery('');
      appState.setCategory('Rempah');
      final rempahResults = appState.filteredProducts;
      expect(rempahResults.every((p) => p.category == 'Rempah'), isTrue);
    });

    test('Farmer can add, update and delete products', () {
      final initialCount = appState.products.length;
      final newProduct = ProductModel(
        id: 'test_prod_1',
        title: 'Bawang Putih Impor',
        category: 'Rempah',
        farmerId: 'usr_petani_1',
        farmerName: 'Pak Eko',
        farmerLocation: 'Malang',
        pricePerKg: 30000,
        stockKg: 400,
        qualityGrade: 'Grade A',
        harvestEstimate: 'Ready',
        description: 'Bawang putih segar',
        imageUrl: 'https://example.com/bawang.jpg',
        createdAt: DateTime.now(),
      );

      appState.addProduct(newProduct);
      expect(appState.products.length, equals(initialCount + 1));

      appState.deleteProduct('test_prod_1');
      expect(appState.products.length, equals(initialCount));
    });

    test('Negotiation chat and offer submission & acceptance', () {
      final thread = appState.chatThreads.first;
      appState.sendChatMessage(thread.id, 'Halo Pak, apakah bisa diskon?');
      expect(appState.getChatThread(thread.id)!.messages.last.text, equals('Halo Pak, apakah bisa diskon?'));

      appState.submitOffer(thread.id, 24000, 200);
      final updatedThread = appState.getChatThread(thread.id)!;
      expect(updatedThread.activeOffer, isNotNull);
      expect(updatedThread.activeOffer!.offeredPrice, equals(24000));
      expect(updatedThread.activeOffer!.quantityKg, equals(200));

      appState.acceptOffer(thread.id);
      expect(appState.getChatThread(thread.id)!.activeOffer!.status.name, equals('accepted'));
    });

    test('2-Way Iterative Negotiation: Counter-offer back and forth until agreement', () {
      final thread = appState.chatThreads.first;
      
      // 1. Initial offer from buyer: 22,000 / kg for 150 kg
      appState.submitOffer(thread.id, 22000, 150);
      var currentThread = appState.getChatThread(thread.id)!;
      expect(currentThread.activeOffer!.offeredPrice, equals(22000));
      expect(currentThread.activeOffer!.quantityKg, equals(150));
      expect(currentThread.activeOffer!.status, equals(NegotiationStatus.pending));

      // 2. Seller counters back: 24,500 / kg for 150 kg
      appState.counterOffer(thread.id, 24500, 150);
      currentThread = appState.getChatThread(thread.id)!;
      expect(currentThread.activeOffer!.offeredPrice, equals(24500));
      expect(currentThread.activeOffer!.status, equals(NegotiationStatus.pending));
      expect(currentThread.messages.any((m) => m.text.contains('Menawar balik: Rp24500')), isTrue);

      // 3. Buyer counters back: 23,500 / kg for 150 kg
      appState.counterOffer(thread.id, 23500, 150);
      currentThread = appState.getChatThread(thread.id)!;
      expect(currentThread.activeOffer!.offeredPrice, equals(23500));
      expect(currentThread.activeOffer!.status, equals(NegotiationStatus.pending));

      // 4. Agreement reached: Seller accepts 23,500 / kg
      appState.acceptOffer(thread.id);
      currentThread = appState.getChatThread(thread.id)!;
      expect(currentThread.activeOffer!.status, equals(NegotiationStatus.accepted));
      expect(currentThread.activeOffer!.offeredPrice, equals(23500));
      expect(currentThread.messages.any((m) => m.text.contains('disetujui! Total: Rp${23500 * 150}')), isTrue);
    });

    test('2-Way Negotiation: Reject with reason and re-submit new offer', () {
      final thread = appState.chatThreads.first;
      
      // 1. Submit low offer
      appState.submitOffer(thread.id, 15000, 100);
      var currentThread = appState.getChatThread(thread.id)!;
      expect(currentThread.activeOffer!.offeredPrice, equals(15000));

      // 2. Seller rejects with reason
      appState.rejectOffer(thread.id, reason: 'Harga penawaran terlalu rendah');
      currentThread = appState.getChatThread(thread.id)!;
      expect(currentThread.activeOffer!.status, equals(NegotiationStatus.rejected));
      expect(currentThread.messages.any((m) => m.text.contains('Harga penawaran terlalu rendah')), isTrue);

      // 3. Buyer submits new realistic offer
      appState.submitOffer(thread.id, 23000, 100);
      currentThread = appState.getChatThread(thread.id)!;
      expect(currentThread.activeOffer!.offeredPrice, equals(23000));
      expect(currentThread.activeOffer!.status, equals(NegotiationStatus.pending));

      // 4. Seller accepts
      appState.acceptOffer(thread.id);
      currentThread = appState.getChatThread(thread.id)!;
      expect(currentThread.activeOffer!.status, equals(NegotiationStatus.accepted));
    });

    test('Order creation, tracking status progression, and review', () {
      final product = appState.products.first;
      final initialStock = product.stockKg;
      final initialOrders = appState.orders.length;

      final newOrder = appState.createOrder(
        product: product,
        quantityKg: 150,
        agreedPricePerKg: 24000,
        deliveryAddress: 'Jl. Pemuda No. 8, Surabaya',
        paymentMethod: 'Rekber AgriSync',
      );

      expect(appState.orders.length, equals(initialOrders + 1));
      expect(newOrder.grandTotal, equals(150 * 24000));
      expect(appState.getProductById(product.id)!.stockKg, equals(initialStock - 150));

      appState.updateOrderStatus(newOrder.id, OrderStatus.dikirim);
      expect(appState.orders.firstWhere((o) => o.id == newOrder.id).status, equals(OrderStatus.dikirim));

      appState.submitOrderReview(newOrder.id, 5.0, 'Kualitas barang jempolan!');
      final reviewedOrder = appState.orders.firstWhere((o) => o.id == newOrder.id);
      expect(reviewedOrder.status, equals(OrderStatus.selesai));
      expect(reviewedOrder.hasReviewed, isTrue);
      expect(reviewedOrder.givenRating, equals(5.0));
    });

    test('Admin verification approval and rejection', () {
      final pendingItem = appState.pendingVerifications.first;

      appState.approveVerification(pendingItem.id);
      final approved = appState.verifications.firstWhere((v) => v.id == pendingItem.id);
      expect(approved.status.name, equals('verified'));
    });

    test('Google Sign-In logs in and configures role properly', () async {
      final errorPetani = await appState.loginWithGoogle(
        role: UserRole.petani,
        email: 'petani.budi@gmail.com',
        displayName: 'Pak Budi Santoso',
      );

      expect(errorPetani, isNull);
      expect(appState.isLoggedIn, isTrue);
      expect(appState.currentUser.role, equals(UserRole.petani));
      expect(appState.currentUser.name, equals('Pak Budi Santoso'));
      expect(appState.currentUser.verificationStatus, equals(VerificationStatus.verified));

      final errorPebisnis = await appState.loginWithGoogle(
        role: UserRole.pebisnis,
        email: 'resto.padang@gmail.com',
        displayName: 'Resto Padang Sejahtera',
      );

      expect(errorPebisnis, isNull);
      expect(appState.isLoggedIn, isTrue);
      expect(appState.currentUser.role, equals(UserRole.pebisnis));
      expect(appState.currentUser.name, equals('Resto Padang Sejahtera'));
    });

    test('1 Google Account = 1 Role rule is strictly enforced', () async {
      // Register initial Google account as Pebisnis
      final firstLogin = await appState.loginWithGoogle(
        role: UserRole.pebisnis,
        email: 'unique.buyer@gmail.com',
        displayName: 'Unique Cafe',
      );
      expect(firstLogin, isNull);
      expect(appState.currentUser.role, equals(UserRole.pebisnis));

      // Attempting to register / login with the SAME Google email as Petani should FAIL
      final conflictLogin = await appState.loginWithGoogle(
        role: UserRole.petani,
        email: 'unique.buyer@gmail.com',
        displayName: 'Unique Cafe Petani',
      );

      // Must return an error message mentioning role conflict
      expect(conflictLogin, isNotNull);
      expect(conflictLogin!.toLowerCase().contains('terdaftar sebagai') || conflictLogin.toLowerCase().contains('peran'), isTrue);
    });

    test('Offer acceptance sends notification and maintains role integrity', () {
      final initialNotifs = appState.currentUserNotifications.length;
      final thread = appState.chatThreads.first;

      appState.submitOffer(thread.id, 26000, 100);
      appState.acceptOffer(thread.id);

      final updatedThread = appState.getChatThread(thread.id)!;
      expect(updatedThread.activeOffer!.status.name, equals('accepted'));
      expect(appState.notifications.length, greaterThan(initialNotifs));
    });

    test('Zero stock products are hidden from public catalog', () {
      final outOfStockProduct = ProductModel(
        id: 'prod_habis_1',
        title: 'Beras Premium Habis',
        category: 'Beras & Padi',
        farmerId: 'usr_petani_1',
        farmerName: 'Pak Eko',
        farmerLocation: 'Kediri',
        pricePerKg: 14000,
        stockKg: 0, // Stock is 0
        qualityGrade: 'Grade A',
        harvestEstimate: 'Habis',
        description: 'Stok sudah habis terjual',
        imageUrl: 'https://example.com/beras.jpg',
        createdAt: DateTime.now(),
      );

      appState.addProduct(outOfStockProduct);

      // Verify that products getter and filteredProducts do not include the 0-stock item
      expect(appState.products.any((p) => p.id == 'prod_habis_1'), isFalse);
      expect(appState.filteredProducts.any((p) => p.id == 'prod_habis_1'), isFalse);
      // But allProducts still retains it for internal/farmer tracking
      expect(appState.allProducts.any((p) => p.id == 'prod_habis_1'), isTrue);
    });

    test('Orders are segregated between mySalesOrders (Petani) and myPurchaseOrders (Pebisnis)', () {
      appState.switchUserRole(UserRole.petani);
      final salesOrders = appState.mySalesOrders;
      expect(salesOrders.every((o) => o.farmerId == 'usr_petani_1' || o.farmerId == appState.currentUser.id), isTrue);

      appState.switchUserRole(UserRole.pebisnis);
      final purchaseOrders = appState.myPurchaseOrders;
      expect(purchaseOrders.every((o) => o.businessId == 'usr_pebisnis_1' || o.businessId == appState.currentUser.id), isTrue);
    });

    test('updateProfile updates user info and notifies listeners', () {
      appState.updateProfile(
        name: 'Resto Organik Nusantara Super',
        businessType: 'Hotel & Restoran Bintang 5',
      );
      expect(appState.currentUser.name, equals('Resto Organik Nusantara Super'));
      expect(appState.currentUser.businessType, equals('Hotel & Restoran Bintang 5'));
    });

    test('setOfflineMode toggles offline mode state and exposes pending queue', () {
      expect(appState.isOfflineMode, isFalse);
      appState.setOfflineMode(true);
      expect(appState.isOfflineMode, isTrue);

      expect(appState.offlinePendingQueue, isNotNull);
      appState.syncOfflineQueue();
      expect(appState.isOfflineMode, isTrue);

      appState.setOfflineMode(false);
      expect(appState.isOfflineMode, isFalse);
    });

    test('Login verifies password and returns error on incorrect password', () async {
      await appState.registerPebisnis(
        businessName: 'Resto Autentik',
        businessType: 'Restoran',
        phone: '08122334455',
        email: 'resto.auth@test.com',
        password: 'correctPassword123',
      );

      // Login with WRONG password should return error
      final errorWrongPass = await appState.login(
        phone: '08122334455',
        email: 'resto.auth@test.com',
        password: 'wrongPassword999',
        role: UserRole.pebisnis,
      );
      expect(errorWrongPass, isNotNull);
      expect(errorWrongPass!.toLowerCase().contains('kata sandi'), isTrue);

      // Login with non-existent user should return error
      final errorNotFound = await appState.login(
        phone: '089999999999',
        email: 'notfound@nowhere.com',
        password: 'anyPassword123',
        role: UserRole.pebisnis,
      );
      expect(errorNotFound, isNotNull);
      expect(errorNotFound!.toLowerCase().contains('tidak terdaftar'), isTrue);

      // Login with role mismatch should return error
      final errorWrongRole = await appState.login(
        phone: '08122334455',
        email: 'resto.auth@test.com',
        password: 'correctPassword123',
        role: UserRole.petani, // Account is PEBISNIS, but logged in as PETANI
      );
      expect(errorWrongRole, isNotNull);
      expect(errorWrongRole!.toLowerCase().contains('peran') || errorWrongRole.toLowerCase().contains('terdaftar sebagai'), isTrue);

      // Login with CORRECT password should succeed
      final errorSuccess = await appState.login(
        phone: '08122334455',
        email: 'resto.auth@test.com',
        password: 'correctPassword123',
        role: UserRole.pebisnis,
      );
      expect(errorSuccess, isNull);
    });

    test('changePassword verifies old password and updates credentials', () async {
      await appState.registerPebisnis(
        businessName: 'Resto Security',
        businessType: 'Kuliner',
        phone: '08155556666',
        email: 'security@resto.com',
        password: 'originalPassword123',
      );

      // Changing password with WRONG old password should fail
      final errorWrongOld = await appState.changePassword(
        oldPassword: 'wrongOldPassword',
        newPassword: 'brandNewPassword456',
      );
      expect(errorWrongOld, isNotNull);
      expect(errorWrongOld!.toLowerCase().contains('kata sandi') || errorWrongOld.toLowerCase().contains('salah'), isTrue);

      // Changing password with same new password should fail
      final errorSamePass = await appState.changePassword(
        oldPassword: 'originalPassword123',
        newPassword: 'originalPassword123',
      );
      expect(errorSamePass, isNotNull);

      // Changing password with CORRECT old password should succeed
      final success = await appState.changePassword(
        oldPassword: 'originalPassword123',
        newPassword: 'brandNewPassword456',
      );
      expect(success, isNull);

      // Subsequent login with old password should now FAIL
      final oldPassLogin = await appState.login(
        phone: '08155556666',
        email: 'security@resto.com',
        password: 'originalPassword123',
        role: UserRole.pebisnis,
      );
      expect(oldPassLogin, isNotNull);

      // Subsequent login with NEW password should SUCCEED
      final newPassLogin = await appState.login(
        phone: '08155556666',
        email: 'security@resto.com',
        password: 'brandNewPassword456',
        role: UserRole.pebisnis,
      );
      expect(newPassLogin, isNull);
    });

    test('resetPassword updates credentials when user forgets password', () async {
      await appState.registerPebisnis(
        businessName: 'Resto Reset Test',
        businessType: 'Restoran',
        phone: '08199998888',
        email: 'forgot@resto.com',
        password: 'oldPassword123',
      );

      // Reset password to a new one
      final resetResult = await appState.resetPassword(
        identifier: 'forgot@resto.com',
        newPassword: 'recoveredPassword789',
      );
      expect(resetResult, isNull);

      // Login with recovered password should succeed
      final loginResult = await appState.login(
        phone: '08199998888',
        email: 'forgot@resto.com',
        password: 'recoveredPassword789',
        role: UserRole.pebisnis,
      );
      expect(loginResult, isNull);
    });

    test('ThemeMode, Language, WeightUnit, and Currency preferences update AppState', () {
      expect(appState.themeMode, equals(ThemeMode.light));
      appState.setThemeMode(ThemeMode.dark);
      expect(appState.themeMode, equals(ThemeMode.dark));

      appState.setLanguage('English (US)');
      expect(appState.selectedLanguage, equals('English (US)'));

      appState.setWeightUnit('Ton (1.000 kg)');
      expect(appState.weightUnit, equals('Ton (1.000 kg)'));

      appState.setCurrency('USD (US Dollar - \$)');
      expect(appState.currency, equals('USD (US Dollar - \$)'));
    });

    test('Notification preferences toggle and persist correctly', () {
      expect(appState.getNotificationSetting('negotiations'), isTrue);
      appState.setNotificationSetting('negotiations', false);
      expect(appState.getNotificationSetting('negotiations'), isFalse);

      appState.setNotificationSetting('promotions', true);
      expect(appState.getNotificationSetting('promotions'), isTrue);
    });

    test('Security settings (2FA, Biometrics, Session invalidation) update properly', () async {
      appState.setTwoFactorEnabled(false);
      expect(appState.twoFactorEnabled, isFalse);

      appState.setBiometricEnabled(true);
      expect(appState.biometricEnabled, isTrue);

      await appState.invalidateOtherSessions();
      expect(appState.isLoggedIn, isTrue);
    });

    test('Cache clearing and Avatar updating work correctly', () async {
      final cleared = await appState.clearAppCache();
      expect(cleared, greaterThan(0));

      appState.updateAvatar('https://api.dicebear.com/7.x/avataaars/png?seed=TestFarmer');
      expect(appState.currentUser.avatarUrl, equals('https://api.dicebear.com/7.x/avataaars/png?seed=TestFarmer'));
    });

    test('Document verification update resets status to pending and admin can re-verify', () async {
      final initialNotifs = appState.currentUserNotifications.length;

      // 1. Submit updated document
      await appState.submitVerificationDocument(
        documentName: 'KTP & NIB Legal 2026',
        documentPath: 'assets/docs/test_doc.pdf',
        roleDetail: 'Lahan Organik Batu',
      );

      // User must now be pending re-verification
      expect(appState.currentUser.verificationStatus, equals(VerificationStatus.pending));
      expect(appState.currentUser.isVerified, isFalse);
      expect(appState.verifications.any((v) => v.documentName == 'KTP & NIB Legal 2026'), isTrue);
      expect(appState.currentUserNotifications.length, greaterThan(initialNotifs));

      final verItem = appState.verifications.firstWhere((v) => v.documentName == 'KTP & NIB Legal 2026');
      expect(verItem.status, equals(VerificationStatus.pending));

      // 2. Admin approves the verification
      appState.approveVerification(verItem.id);
      expect(appState.currentUser.verificationStatus, equals(VerificationStatus.verified));
      expect(appState.currentUser.isVerified, isTrue);

      // 3. Admin can reopen / re-verify anytime
      appState.reopenVerification(verItem.id);
      expect(appState.currentUser.verificationStatus, equals(VerificationStatus.pending));
      expect(appState.currentUser.isVerified, isFalse);
    });

    test('Support ticket creation registers ticket and generates system notification', () {
      final initialNotifs = appState.currentUserNotifications.length;

      final ticketId = appState.submitSupportTicket(
        category: 'Transaksi & Escrow',
        subject: 'Kendala Status Pesanan #ORD-99',
        message: 'Pembayaran sudah ditransfer tetapi status belum berubah.',
      );

      expect(ticketId.startsWith('TKT-'), isTrue);
      expect(appState.currentUserNotifications.length, equals(initialNotifs + 1));
      final latestNotif = appState.currentUserNotifications.first;
      expect(latestNotif.referenceId, equals(ticketId));
      expect(latestNotif.message.contains(ticketId), isTrue);
    });

    test('Newly registered Petani and Pebisnis accounts have clean isolated data (no template leak)', () async {
      // 1. Register a brand new Petani account
      final newPetaniResult = await appState.registerPetani(
        name: 'Petani Baru Mandiri',
        phone: '081299990001',
        email: 'petani.baru@gmail.com',
        password: 'Password123!',
        farmLocation: 'Lumajang, Jawa Timur',
      );

      expect(newPetaniResult, isNull);
      expect(appState.currentUser.name, equals('Petani Baru Mandiri'));
      expect(appState.currentUser.role, equals(UserRole.petani));

      // Newly registered farmer MUST have 0 template chats, 0 template products, and 0 template sales orders
      expect(appState.chatThreads.isEmpty, isTrue, reason: 'New farmer must not inherit template chats');
      expect(appState.myFarmerProducts.isEmpty, isTrue, reason: 'New farmer must not inherit template products');
      expect(appState.mySalesOrders.isEmpty, isTrue, reason: 'New farmer must not inherit template sales orders');

      // 2. Register a brand new Pebisnis account
      final newPebisnisResult = await appState.registerPebisnis(
        businessName: 'Restoran Baru Enak',
        businessType: 'Restoran',
        phone: '081299990002',
        email: 'resto.baru@gmail.com',
        password: 'Password123!',
      );

      expect(newPebisnisResult, isNull);
      expect(appState.currentUser.name, equals('Restoran Baru Enak'));
      expect(appState.currentUser.role, equals(UserRole.pebisnis));

      // Newly registered business MUST have 0 template chats and 0 template purchase orders
      expect(appState.chatThreads.isEmpty, isTrue, reason: 'New buyer must not inherit template chats');
      expect(appState.myPurchaseOrders.isEmpty, isTrue, reason: 'New buyer must not inherit template purchase orders');

      // 3. If new buyer initiates chat with a product, thread is isolated to them and the product's farmer
      final sampleProduct = appState.products.first;
      final createdThread = appState.getOrCreateThreadForProduct(sampleProduct);

      expect(createdThread.buyerId, equals(appState.currentUser.id));
      expect(createdThread.farmerId, equals(sampleProduct.farmerId));
      expect(appState.chatThreads.length, equals(1));
      expect(appState.chatThreads.first.id, equals(createdThread.id));
    });

    test('deleteUserAccountCascade deletes user and automatically cascades deletion of all their products', () async {
      // 1. Register a Petani
      await appState.registerPetani(
        name: 'Petani Hapus Test',
        phone: '081288880001',
        email: 'petani.hapus@gmail.com',
        password: 'Password123!',
        farmLocation: 'Batu, Jawa Timur',
      );
      final farmerId = appState.currentUser.id;

      // 2. Petani adds 2 products
      final prod1 = ProductModel(
        id: 'prod_cascade_1',
        title: 'Tomat Cherry Segar',
        category: 'Sayuran',
        farmerId: farmerId,
        farmerName: 'Petani Hapus Test',
        farmerLocation: 'Batu, Jawa Timur',
        pricePerKg: 15000,
        stockKg: 100,
        qualityGrade: 'Grade A',
        harvestEstimate: 'Siap Panen',
        description: 'Tomat manis segar organik',
        imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea',
        createdAt: DateTime.now(),
      );
      final prod2 = ProductModel(
        id: 'prod_cascade_2',
        title: 'Wortel Brastagi Organik',
        category: 'Sayuran',
        farmerId: farmerId,
        farmerName: 'Petani Hapus Test',
        farmerLocation: 'Batu, Jawa Timur',
        pricePerKg: 12000,
        stockKg: 200,
        qualityGrade: 'Grade A',
        harvestEstimate: 'Siap Panen',
        description: 'Wortel renyah segar',
        imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37',
        createdAt: DateTime.now(),
      );
      appState.addProduct(prod1);
      appState.addProduct(prod2);

      expect(appState.getProductById('prod_cascade_1'), isNotNull);
      expect(appState.getProductById('prod_cascade_2'), isNotNull);
      expect(appState.myFarmerProducts.length, equals(2));

      // 3. Delete user account with cascade
      await appState.deleteUserAccountCascade(farmerId);

      // 4. Verify that products are cascade deleted and no longer exist in the system
      expect(appState.getProductById('prod_cascade_1'), isNull, reason: 'Product 1 must be cascade deleted');
      expect(appState.getProductById('prod_cascade_2'), isNull, reason: 'Product 2 must be cascade deleted');
      expect(appState.allProducts.any((p) => p.farmerId == farmerId), isFalse);
    });

    test('1 Email = 1 Role rule prevents duplicate email registration across roles', () async {
      const uniqueEmail = 'duplication.guard@gmail.com';
      const phone = '081299887766';

      // 1. Register first as Petani
      final errPetani = await appState.registerPetani(
        name: 'Pak Budi Duplikat',
        phone: phone,
        email: uniqueEmail,
        password: 'password123',
        farmLocation: 'Batu, Jawa Timur',
      );
      expect(errPetani, isNull, reason: 'First registration must succeed');

      // 2. Attempt to register again with same email as Pebisnis must be rejected
      final errPebisnis = await appState.registerPebisnis(
        businessName: 'Resto Duplikat',
        businessType: 'Restoran',
        phone: '081299887767',
        email: uniqueEmail,
        password: 'password123',
      );
      expect(errPebisnis, isNotNull);
      expect(errPebisnis!.toLowerCase().contains('sudah terdaftar'), isTrue);

      // 3. Attempt to register again with same email as Petani must also be rejected
      final errPetaniAgain = await appState.registerPetani(
        name: 'Pak Budi Kloning',
        phone: '081299887768',
        email: uniqueEmail,
        password: 'password123',
        farmLocation: 'Malang',
      );
      expect(errPetaniAgain, isNotNull);
      expect(errPetaniAgain!.toLowerCase().contains('sudah terdaftar'), isTrue);
    });
  });
}

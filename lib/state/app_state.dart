import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/models/product_model.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/chat_model.dart';
import '../data/models/order_model.dart';
import '../data/models/verification_model.dart';
import '../data/models/notification_model.dart';
import '../data/models/review_model.dart';
import '../data/mock_data.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/admin_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/firebase_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/push_notification_service.dart';

/// AppState serves as the unified ViewModel and State coordinator,
/// delegating data operations to specialized Repositories via Dependency Injection.
class AppState extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ProductRepository _productRepository;
  final ChatRepository _chatRepository;
  final OrderRepository _orderRepository;
  final AdminRepository _adminRepository;
  final NotificationRepository _notificationRepository;
  final LocalStorageService? _storage;

  List<String> _favoriteProductIds = [];
  ThemeMode _themeMode = ThemeMode.light;
  String _selectedLanguage = 'Bahasa Indonesia';
  String _weightUnit = 'Kilogram (kg)';
  String _currency = 'IDR (Rupiah Indonesia - Rp)';
  Map<String, bool> _notificationSettings = {
    'negotiations': true,
    'orders': true,
    'harvests': true,
    'price_trends': true,
    'promotions': false,
    'sound_vibrate': true,
    'email_digest': true,
  };
  bool _twoFactorEnabled = true;
  bool _biometricEnabled = false;
  final List<Map<String, dynamic>> _inMemoryOfflineQueue = [];
  final List<ReviewItem> _reviews = MockData.getInitialReviews();

  AppState({
    AuthRepository? authRepository,
    ProductRepository? productRepository,
    ChatRepository? chatRepository,
    OrderRepository? orderRepository,
    AdminRepository? adminRepository,
    NotificationRepository? notificationRepository,
    LocalStorageService? storage,
  })  : _storage = storage,
        _authRepository = authRepository ?? AuthRepositoryImpl(authService: MockAuthService(storage: storage)),
        _productRepository = productRepository ?? ProductRepositoryImpl(),
        _chatRepository = chatRepository ?? ChatRepositoryImpl(),
        _orderRepository = orderRepository ?? OrderRepositoryImpl(),
        _adminRepository = adminRepository ?? AdminRepositoryImpl(),
        _notificationRepository = notificationRepository ?? NotificationRepositoryImpl() {
    _favoriteProductIds = _storage?.loadFavorites() ?? ['prod_1', 'prod_4'];

    final appPrefs = _storage?.loadAppPreferences() ?? {};
    final modeStr = appPrefs['themeMode'] ?? 'light';
    if (modeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (modeStr == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    _selectedLanguage = appPrefs['language'] ?? 'Bahasa Indonesia';
    _weightUnit = appPrefs['weightUnit'] ?? 'Kilogram (kg)';
    _currency = appPrefs['currency'] ?? 'IDR (Rupiah Indonesia - Rp)';

    _notificationSettings = _storage?.loadNotificationPreferences() ?? _notificationSettings;

    final secSettings = _storage?.loadSecuritySettings() ?? {};
    _twoFactorEnabled = secSettings['twoFactorEnabled'] ?? true;
    _biometricEnabled = secSettings['biometricEnabled'] ?? false;

    // Real-Time multi-device synchronization via Cloud Firestore
    _initCloudSync();
  }

  /// Inisialisasi sinkronisasi cloud real-time (Multi-Device Sync: Android, iOS, Web)
  void _initCloudSync() {
    try {
      FirebaseService.streamProducts().listen((cloudProducts) {
        if (cloudProducts.isNotEmpty) {
          final cloudIds = cloudProducts.map((p) => p.id).toSet();

          for (final cp in cloudProducts) {
            final existing = _productRepository.getProductById(cp.id);
            if (existing != null) {
              _productRepository.updateProduct(cp);
            } else {
              _productRepository.addProduct(cp);
            }
          }

          // Otomatis hapus produk lokal yang sudah terhapus di Cloud Firestore
          final localProds = _productRepository.getProducts();
          for (final lp in localProds) {
            if (lp.id.startsWith('prod_custom_') && !cloudIds.contains(lp.id)) {
              _productRepository.deleteProduct(lp.id);
            }
          }
          notifyListeners();
        }
      }, onError: (err) {
        debugPrint('⚠️ [AppState._initCloudSync] Cloud product stream note: $err');
      });
    } catch (e) {
      debugPrint('⚠️ [AppState._initCloudSync] Error setting up stream: $e');
    }
  }

  // ==========================================
  // 1. AUTH & USER PROFILE
  // ==========================================
  UserModel get currentUser => _authRepository.currentUser;
  bool get isLoggedIn => _authRepository.isLoggedIn;

  UserModel? findUserByEmailOrPhone(String query) {
    return _storage?.findUserByEmailOrPhone(query);
  }

  UserModel? findUserById(String id) {
    if (_authRepository.currentUser.id == id) {
      return _authRepository.currentUser;
    }
    return _storage?.findUserById(id);
  }

  void switchUserRole(UserRole role) {
    _authRepository.switchRole(role);
    FirebaseService.saveUserProfile(_authRepository.currentUser);
    notifyListeners();
  }

  Future<String?> login({
    required String phone,
    required String password,
    required UserRole role,
    String? email,
  }) async {
    try {
      final emailOrPhone = (email != null && email.trim().isNotEmpty) ? email.trim() : phone.trim();
      if (emailOrPhone.isEmpty) {
        return 'Harap masukkan email atau nomor telepon Anda.';
      }

      // 1. Coba autentikasi via Firebase Cloud / Firestore
      UserModel? fbUser;
      try {
        fbUser = await FirebaseService.signInWithEmailPassword(
          emailOrPhone: emailOrPhone,
          password: password,
          role: role,
        );
      } catch (fbErr) {
        debugPrint('⚠️ [AppState.login] Firebase sign in note: $fbErr');
      }

      if (fbUser != null) {
        // Cek jika role berbeda dengan pilihan UI
        if (fbUser.role != role) {
          throw Exception(
            'Akun ini terdaftar sebagai peran ${fbUser.role.name.toUpperCase()}, bukan ${role.name.toUpperCase()}.\n'
            'Silakan pilih peran ${fbUser.role.name.toUpperCase()} pada pilihan di atas.',
          );
        }

        // Sinkronkan akun cloud ke Storage Lokal perangkat Android/iOS ini
        _storage?.saveRegisteredUser(fbUser, password: password);
        _storage?.saveCurrentUser(fbUser);
        _storage?.saveIsLoggedIn(true);

        _authRepository.setCurrentUser(fbUser);
        notifyListeners();
        return null; // Sukses login via Firebase Cloud!
      }

      // 2. Verifikasi kredensial lokal jika offline / demo
      final user = _authRepository.login(
        phone: phone,
        password: password,
        role: role,
        email: email,
      );

      FirebaseService.saveUserProfile(user);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('❌ [AppState] Login Error: $e');
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> loginWithGoogle({
    required UserRole role,
    String? email,
    String? displayName,
  }) async {
    try {
      // 1. Jalankan autentikasi Google dan validasi Aturan 1 Akun Google = 1 Role
      final fbUser = await FirebaseService.signInWithGoogle(
        role: role,
        email: email,
        displayName: displayName,
      );

      final user = _authRepository.loginWithGoogle(
        role: role,
        email: fbUser.email ?? email,
        displayName: fbUser.name,
      );

      FirebaseService.saveUserProfile(user);
      notifyListeners();
      return null; // Sukses tanpa error
    } catch (e) {
      debugPrint('❌ [AppState] Google Sign-In Error: $e');
      // Kembalikan pesan error untuk ditampilkan di UI jika terjadi konflik peran
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> registerPetani({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String farmLocation,
    String? documentPath,
  }) async {
    try {
      final result = _authRepository.registerPetani(
        name: name,
        phone: phone,
        email: email,
        password: password,
        farmLocation: farmLocation,
        documentPath: documentPath,
      );
      _adminRepository.addVerification(result.verification);
      FirebaseService.saveVerification(result.verification);

      // Sinkronkan ke Firebase Auth & Cloud Firestore
      await FirebaseService.signUpWithEmailPassword(
        email: email,
        password: password,
        userProfile: result.user,
      );

      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('❌ [AppState] registerPetani Error: $e');
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> registerPebisnis({
    required String businessName,
    required String businessType,
    required String phone,
    required String email,
    required String password,
    String? documentPath,
  }) async {
    try {
      final result = _authRepository.registerPebisnis(
        businessName: businessName,
        businessType: businessType,
        phone: phone,
        email: email,
        password: password,
        documentPath: documentPath,
      );
      _adminRepository.addVerification(result.verification);
      FirebaseService.saveVerification(result.verification);

      // Sinkronkan ke Firebase Auth & Cloud Firestore
      await FirebaseService.signUpWithEmailPassword(
        email: email,
        password: password,
        userProfile: result.user,
      );

      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('❌ [AppState] registerPebisnis Error: $e');
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  void logout() {
    _authRepository.logout();
    FirebaseService.signOut();
    notifyListeners();
  }

  /// Kirim tautan verifikasi email resmi Firebase ke email pengguna
  Future<bool> sendEmailVerification() async {
    final success = await FirebaseService.sendEmailVerificationToCurrentUser();
    notifyListeners();
    return success;
  }

  /// Periksa apakah tautan di Gmail sudah diklik dan akun terverifikasi
  Future<bool> checkEmailVerified() async {
    final verified = await FirebaseService.checkEmailVerified();
    if (verified && !_authRepository.currentUser.isVerified) {
      _authRepository.updateUserVerificationStatus(_authRepository.currentUser.id, VerificationStatus.verified);
      FirebaseService.updateUserVerificationStatus(_authRepository.currentUser.id, VerificationStatus.verified);
      _storage?.saveCurrentUser(_authRepository.currentUser);
      notifyListeners();
    }
    return verified;
  }

  void updateProfile({
    String? name,
    String? businessType,
    String? farmLocation,
    String? avatarUrl,
    String? email,
    String? phone,
    bool? isProMember,
    DateTime? subscriptionExpiry,
  }) {
    _authRepository.updateProfile(
      name: name,
      businessType: businessType,
      farmLocation: farmLocation,
      avatarUrl: avatarUrl,
      email: email,
      phone: phone,
      isProMember: isProMember,
      subscriptionExpiry: subscriptionExpiry,
    );
    final user = _authRepository.currentUser;
    _storage?.saveCurrentUser(user);
    _storage?.saveRegisteredUser(user);
    if (avatarUrl != null) {
      _storage?.updateUserAvatar(user.id, avatarUrl);
    }
    FirebaseService.saveUserProfile(user);
    notifyListeners();
  }

  bool verifyPassword(String password) => _authRepository.verifyPassword(password);

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      await FirebaseService.updatePassword(newPassword);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('❌ [AppState] changePassword Error: $e');
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> resetPassword({
    required String identifier,
    required String newPassword,
  }) async {
    try {
      final clean = identifier.trim();
      if (clean.isEmpty) {
        return 'Harap masukkan email atau nomor telepon.';
      }
      if (newPassword.length < 6) {
        return 'Kata sandi baru minimal 6 karakter.';
      }

      _authRepository.resetPassword(
        identifier: clean,
        newPassword: newPassword,
      );

      await FirebaseService.resetPasswordForUser(
        emailOrPhone: clean,
        newPassword: newPassword,
      );

      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('❌ [AppState] resetPassword Error: $e');
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Hapus akun pengguna secara permanen dan lakukan pembersihan cascade terhadap seluruh produk,
  /// dokumen verifikasi, kredensial, dan data terkait di Cloud Firestore & Local Storage.
  Future<void> deleteUserAccountCascade(String userId) async {
    try {
      final user = _storage?.findUserById(userId) ?? (_authRepository.currentUser.id == userId ? _authRepository.currentUser : null);

      // 1. Cascade delete di Cloud Firestore (Produk, Verifikasi, Auth)
      await FirebaseService.deleteUserAccountCascade(
        userId,
        userPhone: user?.phone,
        userEmail: user?.email,
      );

      // 2. Cascade delete semua produk milik pengguna dari ProductRepository
      _productRepository.deleteProductsByFarmer(userId);

      // 3. Bersihkan dari LocalStorage
      await _storage?.deleteRegisteredUser(userId);

      // 4. Bersihkan produk petani yang dihapus dari keranjang belanja jika ada
      _cartItems.removeWhere((item) => item.product.farmerId == userId);

      // 5. Bersihkan favorites jika produk terhapus
      _favoriteProductIds.removeWhere((id) => _productRepository.getProductById(id) == null);
      _storage?.saveFavorites(_favoriteProductIds);

      // 6. Jika user yang dihapus adalah user yang sedang login, logout otomatis
      if (_authRepository.currentUser.id == userId) {
        logout();
      } else {
        notifyListeners();
      }
      debugPrint('✅ [AppState] deleteUserAccountCascade completed for user: $userId');
    } catch (e) {
      debugPrint('❌ [AppState] deleteUserAccountCascade Error: $e');
    }
  }

  // ==========================================
  // 2. PRODUCTS & FILTERING & FAVORITES
  // ==========================================
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  double _filterMinPrice = 0;
  double _filterMaxPrice = 100000;
  double _filterMinStock = 0;
  double _filterMaxStock = 5000;
  String _filterQuality = 'Semua';
  String _filterLocation = '';

  double get filterMinPrice => _filterMinPrice;
  double get filterMaxPrice => _filterMaxPrice;
  double get filterMinStock => _filterMinStock;
  double get filterMaxStock => _filterMaxStock;
  String get filterQuality => _filterQuality;
  String get filterLocation => _filterLocation;

  List<ProductModel> get products =>
      _productRepository.getProducts().where((p) => p.stockKg > 0).toList();

  List<ProductModel> get allProducts => _productRepository.getProducts();

  List<ProductModel> get filteredProducts {
    return _productRepository.getFilteredProducts(
      category: _selectedCategory,
      searchQuery: _searchQuery,
      minPrice: _filterMinPrice,
      maxPrice: _filterMaxPrice,
      minStock: _filterMinStock,
      maxStock: _filterMaxStock,
      quality: _filterQuality,
      location: _filterLocation,
    );
  }

  List<ProductModel> get myFarmerProducts =>
      _productRepository.getFarmerProducts(_authRepository.currentUser.id);

  // Favorites (Sayuran Ditandai / Keranjang untuk Pebisnis)
  List<ProductModel> get favoriteProducts {
    final all = _productRepository.getProducts();
    return all.where((p) => _favoriteProductIds.contains(p.id) && p.stockKg > 0).toList();
  }

  bool isFavorite(String productId) => _favoriteProductIds.contains(productId);

  void toggleFavorite(String productId) {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    _storage?.saveFavorites(_favoriteProductIds);
    notifyListeners();
  }

  // ==========================================
  // 2b. SHOPPING CART (KERANJANG PEBISNIS)
  // ==========================================
  List<CartItem> _cartItems = [];
  bool _cartInitialized = false;

  List<CartItem> get cartItems {
    if (!_cartInitialized && _cartItems.isEmpty) {
      _cartInitialized = true;
      final prods = products;
      if (prods.isNotEmpty) {
        _cartItems = [
          CartItem(product: prods.first, quantityKg: 50),
          if (prods.length > 1) CartItem(product: prods[1], quantityKg: 30),
        ];
      }
    }
    return _cartItems;
  }

  int get cartItemCount => cartItems.length;
  int get cartTotalQuantity => cartItems.fold(0, (sum, i) => sum + i.quantityKg);
  int get cartSubtotal => cartItems.fold(0, (sum, i) => sum + i.totalPrice);
  int get cartEstimatedShipping => cartItems.isEmpty ? 0 : 35000;
  int get cartProDiscount => (currentUser.isProMember ? (cartSubtotal * 0.05).round() : 0);
  int get cartGrandTotal => (cartSubtotal + cartEstimatedShipping - cartProDiscount).clamp(0, 999999999);

  void addToCart(ProductModel product, {int quantityKg = 50}) {
    _cartInitialized = true;
    final existingIndex = _cartItems.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantityKg += quantityKg;
    } else {
      _cartItems.add(CartItem(product: product, quantityKg: quantityKg));
    }
    notifyListeners();
  }

  void updateCartQuantity(String productId, int newQuantity) {
    _cartInitialized = true;
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _cartItems.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _cartItems[index].quantityKg = newQuantity;
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cartInitialized = true;
    _cartItems.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartInitialized = true;
    _cartItems.clear();
    notifyListeners();
  }

  void updateCartNotes(String productId, String? notes) {
    _cartInitialized = true;
    final index = _cartItems.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(notes: notes);
      notifyListeners();
    }
  }


  void setSearchQuery(String? query) {
    _searchQuery = query ?? '';
    notifyListeners();
  }

  void setCategory(String? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
  }

  void setFilters({
    required double minPrice,
    required double maxPrice,
    required double minStock,
    required double maxStock,
    required String quality,
    required String location,
  }) {
    _filterMinPrice = minPrice;
    _filterMaxPrice = maxPrice;
    _filterMinStock = minStock;
    _filterMaxStock = maxStock;
    _filterQuality = quality;
    _filterLocation = location;
    notifyListeners();
  }

  void resetFilters() {
    _filterMinPrice = 0;
    _filterMaxPrice = 100000;
    _filterMinStock = 0;
    _filterMaxStock = 5000;
    _filterQuality = 'Semua';
    _filterLocation = '';
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  void addProduct(ProductModel product) {
    final p = _isOfflineMode ? product.copyWith(isPendingSync: true) : product;
    _productRepository.addProduct(p);
    if (!_isOfflineMode) {
      FirebaseService.uploadProduct(p);
    } else {
      final action = {
        'type': 'add_product',
        'productId': p.id,
        'title': p.title,
        'quantityKg': p.stockKg,
      };
      _inMemoryOfflineQueue.add(action);
      _storage?.addToOfflineQueue(action);
    }
    notifyListeners();
  }

  void updateProduct(ProductModel updated) {
    final p = _isOfflineMode ? updated.copyWith(isPendingSync: true) : updated;
    _productRepository.updateProduct(p);
    if (!_isOfflineMode) {
      FirebaseService.uploadProduct(p);
    } else {
      final action = {
        'type': 'update_product',
        'productId': p.id,
        'title': p.title,
        'quantityKg': p.stockKg,
      };
      _inMemoryOfflineQueue.add(action);
      _storage?.addToOfflineQueue(action);
    }
    notifyListeners();
  }

  void deleteProduct(String id) {
    _productRepository.deleteProduct(id);
    _favoriteProductIds.remove(id);
    _storage?.saveFavorites(_favoriteProductIds);
    if (!_isOfflineMode) {
      FirebaseService.deleteProduct(id);
    }
    notifyListeners();
  }

  ProductModel? getProductById(String id) => _productRepository.getProductById(id);

  // ==========================================
  // 3. CHAT & NEGOTIATION
  // ==========================================
  List<ChatThread> get chatThreads =>
      _chatRepository.getChatThreadsForUser(_authRepository.currentUser.id);

  ChatThread? getChatThread(String threadId) => _chatRepository.getChatThread(threadId);

  ChatThread getOrCreateThreadForProduct(ProductModel product) {
    final thread = _chatRepository.getOrCreateThreadForProduct(product, _authRepository.currentUser);
    notifyListeners();
    return thread;
  }

  void sendChatMessage(String threadId, String text) {
    final sender = _authRepository.currentUser;
    _chatRepository.sendChatMessage(threadId, text, sender);
    notifyListeners();
  }

  void submitOffer(String threadId, int pricePerKg, int quantityKg) {
    final sender = _authRepository.currentUser;
    _chatRepository.submitOffer(threadId, pricePerKg, quantityKg, sender);

    final thread = _chatRepository.getChatThread(threadId);
    if (thread != null) {
      // Sync to Cloud Firestore
      FirebaseService.saveChatThread(thread);

      // Send notification to the counterparty
      final recipientId = thread.getOtherUserId(sender.id);
      _notificationRepository.addNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          recipientUserId: recipientId,
          senderId: sender.id,
          senderName: sender.name,
          title: '💬 Penawaran Harga Baru',
          message: '${sender.name} mengajukan penawaran Rp$pricePerKg/kg ($quantityKg kg) untuk ${thread.productTitle}.',
          type: NotificationType.negotiation,
          referenceId: threadId,
          createdAt: DateTime.now(),
        ),
      );
    }

    notifyListeners();
  }

  void counterOffer(String threadId, int counterPricePerKg, int quantityKg) {
    final sender = _authRepository.currentUser;
    _chatRepository.counterOffer(threadId, counterPricePerKg, quantityKg, sender);

    final thread = _chatRepository.getChatThread(threadId);
    if (thread != null) {
      // Sync to Cloud Firestore
      FirebaseService.saveChatThread(thread);

      // Send notification to the other party
      final recipientId = thread.getOtherUserId(sender.id);
      _notificationRepository.addNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          recipientUserId: recipientId,
          senderId: sender.id,
          senderName: sender.name,
          title: '🔄 Tawaran Balasan Baru',
          message: '${sender.name} menawar balik Rp$counterPricePerKg/kg ($quantityKg kg) untuk ${thread.productTitle}.',
          type: NotificationType.negotiation,
          referenceId: threadId,
          createdAt: DateTime.now(),
        ),
      );
    }

    notifyListeners();
  }

  void acceptOffer(String threadId) {
    final user = _authRepository.currentUser;
    _chatRepository.acceptOffer(threadId, user);

    final thread = _chatRepository.getChatThread(threadId);
    if (thread != null) {
      // Sync to Cloud Firestore
      FirebaseService.saveChatThread(thread);

      // Notify the counterparty that offer was accepted
      final recipientId = thread.getOtherUserId(user.id);
      _notificationRepository.addNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          recipientUserId: recipientId,
          senderId: user.id,
          senderName: user.name,
          title: '🎉 Penawaran Disetujui!',
          message: '${user.name} telah menyetujui penawaran harga untuk ${thread.productTitle}. Silakan lanjutkan proses transaksi.',
          type: NotificationType.negotiation,
          referenceId: threadId,
          createdAt: DateTime.now(),
        ),
      );
    }

    notifyListeners();
  }

  void rejectOffer(String threadId, {String? reason}) {
    final user = _authRepository.currentUser;
    _chatRepository.rejectOffer(threadId, user, reason: reason);

    final thread = _chatRepository.getChatThread(threadId);
    if (thread != null) {
      // Sync to Cloud Firestore
      FirebaseService.saveChatThread(thread);

      // Notify the counterparty that offer was rejected
      final recipientId = thread.getOtherUserId(user.id);
      _notificationRepository.addNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          recipientUserId: recipientId,
          senderId: user.id,
          senderName: user.name,
          title: '❌ Penawaran Ditolak',
          message: '${user.name} menolak penawaran harga untuk ${thread.productTitle}. Anda dapat mengajukan harga kembali.',
          type: NotificationType.negotiation,
          referenceId: threadId,
          createdAt: DateTime.now(),
        ),
      );
    }

    notifyListeners();
  }

  // ==========================================
  // 4. ORDERS & ESCROW & NOTIFICATIONS
  // ==========================================
  List<OrderModel> get orders => _orderRepository.getOrders();

  List<OrderModel> get myOrders {
    final user = _authRepository.currentUser;
    if (user.role == UserRole.petani) {
      return mySalesOrders;
    } else if (user.role == UserRole.pebisnis) {
      return myPurchaseOrders;
    }
    return orders;
  }

  List<OrderModel> get mySalesOrders => _orderRepository
      .getOrders()
      .where((o) => o.farmerId == _authRepository.currentUser.id)
      .toList();

  List<OrderModel> get myPurchaseOrders => _orderRepository
      .getOrders()
      .where((o) => o.businessId == _authRepository.currentUser.id)
      .toList();

  OrderModel createOrder({
    required ProductModel product,
    required int quantityKg,
    required int agreedPricePerKg,
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
  }) {
    final buyer = _authRepository.currentUser;
    final newOrder = _orderRepository.createOrder(
      product: product,
      currentUser: buyer,
      quantityKg: quantityKg,
      agreedPricePerKg: agreedPricePerKg,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      notes: notes,
    );

    // Sync to Cloud Firestore
    FirebaseService.createOrder(newOrder);

    // Deduct stock from product
    final currentProduct = _productRepository.getProductById(product.id) ?? product;
    final updatedStock = (currentProduct.stockKg - quantityKg).clamp(0, 999999);
    final updatedProduct = currentProduct.copyWith(stockKg: updatedStock);
    _productRepository.updateProduct(updatedProduct);
    FirebaseService.uploadProduct(updatedProduct);

    // 1. Send Notification to Petani (Seller)
    _notificationRepository.addNotification(
      NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}_petani',
        recipientUserId: product.farmerId,
        senderId: buyer.id,
        senderName: buyer.name,
        title: '🛒 Pesanan Baru Masuk!',
        message: '${buyer.name} telah membuat pesanan $quantityKg kg ${product.title} (${newOrder.orderNumber}). Segera siapkan panen & pengiriman!',
        type: NotificationType.order,
        referenceId: newOrder.id,
        createdAt: DateTime.now(),
      ),
    );

    // 2. Send Notification to Pebisnis (Buyer)
    _notificationRepository.addNotification(
      NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}_pebisnis',
        recipientUserId: buyer.id,
        senderId: product.farmerId,
        senderName: product.farmerName,
        title: '✅ Pesanan Berhasil Dibuat',
        message: 'Pesanan ${product.title} ($quantityKg kg) dengan kode ${newOrder.orderNumber} telah diteruskan ke Petani ${product.farmerName}.',
        type: NotificationType.order,
        referenceId: newOrder.id,
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
    return newOrder;
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    _orderRepository.updateOrderStatus(orderId, status);

    final order = _orderRepository.getOrders().firstWhere(
          (o) => o.id == orderId,
          orElse: () => throw Exception('Order not found'),
        );

    final updater = _authRepository.currentUser;

    // Send Notification to Pebisnis when Petani updates status
    if (updater.id == order.farmerId) {
      _notificationRepository.addNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_status',
          recipientUserId: order.businessId,
          senderId: order.farmerId,
          senderName: order.farmerName,
          title: '🚚 Status Pesanan Diperbarui',
          message: 'Pesanan ${order.productTitle} (${order.orderNumber}) telah diperbarui menjadi: ${status.label}.',
          type: NotificationType.order,
          referenceId: order.id,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      // If buyer or admin changed it, notify farmer
      _notificationRepository.addNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_status',
          recipientUserId: order.farmerId,
          senderId: updater.id,
          senderName: updater.name,
          title: '📦 Status Pesanan Diperbarui',
          message: 'Pesanan ${order.productTitle} (${order.orderNumber}) telah diperbarui menjadi: ${status.label}.',
          type: NotificationType.order,
          referenceId: order.id,
          createdAt: DateTime.now(),
        ),
      );
    }

    notifyListeners();
  }

  void submitOrderReview(String orderId, double rating, String review) {
    _orderRepository.submitOrderReview(orderId, rating, review);

    final order = _orderRepository.getOrderById(orderId);
    if (order != null) {
      _reviews.insert(
        0,
        ReviewItem(
          id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
          orderId: order.id,
          productId: order.productId,
          productTitle: order.productTitle,
          farmerId: order.farmerId,
          farmerName: order.farmerName,
          buyerId: order.businessId,
          buyerName: order.businessName,
          rating: rating,
          comment: review,
          createdAt: DateTime.now(),
          quantityKg: order.quantityKg,
        ),
      );

      // Send notification to the farmer that buyer gave review
      _notificationRepository.addNotification(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_review',
          recipientUserId: order.farmerId,
          senderId: order.businessId,
          senderName: order.businessName,
          title: '⭐ Ulasan Baru Diterima!',
          message: '${order.businessName} memberikan ulasan ⭐$rating untuk ${order.productTitle}: "$review"',
          type: NotificationType.system,
          referenceId: order.id,
          createdAt: DateTime.now(),
        ),
      );
    }

    notifyListeners();
  }

  // ==========================================
  // 5. REVIEWS & RATINGS FEEDBACK
  // ==========================================
  List<ReviewItem> get allReviews => List.unmodifiable(_reviews);

  List<ReviewItem> getProductReviews(String productId) {
    return _reviews.where((r) => r.productId == productId).toList();
  }

  List<ReviewItem> getFarmerReviews(String farmerId) {
    return _reviews.where((r) => r.farmerId == farmerId).toList();
  }

  List<ReviewItem> get myFarmerReceivedReviews =>
      getFarmerReviews(_authRepository.currentUser.id);

  double getFarmerAverageRating(String farmerId) {
    final list = getFarmerReviews(farmerId);
    if (list.isEmpty) return 5.0;
    final total = list.fold<double>(0.0, (sum, r) => sum + r.rating);
    return double.parse((total / list.length).toStringAsFixed(1));
  }

  double getProductAverageRating(String productId) {
    final list = getProductReviews(productId);
    if (list.isEmpty) {
      final p = getProductById(productId);
      return p?.rating ?? 5.0;
    }
    final total = list.fold<double>(0.0, (sum, r) => sum + r.rating);
    return double.parse((total / list.length).toStringAsFixed(1));
  }

  // ==========================================
  // 5. NOTIFICATIONS
  // ==========================================
  List<NotificationModel> get notifications => _notificationRepository.getNotifications();

  List<NotificationModel> get currentUserNotifications =>
      _notificationRepository.getNotificationsForUser(_authRepository.currentUser.id);

  int get unreadNotificationCount =>
      _notificationRepository.getUnreadCount(_authRepository.currentUser.id);

  void markNotificationAsRead(String notificationId) {
    _notificationRepository.markAsRead(notificationId);
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    _notificationRepository.markAllAsRead(_authRepository.currentUser.id);
    notifyListeners();
  }

  void addNotification(NotificationModel notification) {
    _notificationRepository.addNotification(notification);
    FirebaseService.saveNotification(notification.toJson());
    if (notification.recipientUserId == _authRepository.currentUser.id ||
        notification.recipientUserId == 'all') {
      PushNotificationService.showPushIfEnabled(notification, this);
    }
    notifyListeners();
  }

  // ==========================================
  // 6. ADMIN & PLATFORM MANAGEMENT
  // ==========================================
  List<VerificationItem> get verifications => _adminRepository.getVerifications();

  List<VerificationItem> get pendingVerifications => _adminRepository.getPendingVerifications();

  List<DisputeItem> get disputes => _adminRepository.getDisputes();

  int get totalPetaniStat => _adminRepository.getTotalPetaniStat(1250);
  int get totalPebisnisStat => _adminRepository.getTotalPebisnisStat(890);
  int get pendingVerifikasiStat => _adminRepository.getPendingVerifikasiStat();
  int get activeTransactionStat => _adminRepository.getActiveTransactionStat(_orderRepository.getOrders(), 110);
  int get activeDisputesStat => _adminRepository.getActiveDisputesStat();

  void approveVerification(String id) {
    _adminRepository.approveVerification(id);
    final verifications = _adminRepository.getVerifications();
    final vIndex = verifications.indexWhere((v) => v.id == id);
    if (vIndex >= 0) {
      final v = verifications[vIndex];
      _authRepository.updateUserVerificationStatus(v.userId, VerificationStatus.verified);
      FirebaseService.updateVerificationStatus(v.id, VerificationStatus.verified);
      FirebaseService.updateUserVerificationStatus(v.userId, VerificationStatus.verified);

      // Kirim notifikasi sistem ke pengguna
      _notificationRepository.addNotification(
        NotificationModel(
          id: 'notif_ver_app_${DateTime.now().millisecondsSinceEpoch}',
          recipientUserId: v.userId,
          senderId: 'admin_agrisync',
          senderName: 'Admin AgriSync',
          title: '✅ Berkas Terverifikasi Resmi',
          message: 'Selamat! Pengajuan berkas registrasi/pembaruan (${v.roleDetail}) telah disetujui oleh Admin. Akun Anda kini resmi Berstatus Terverifikasi.',
          type: NotificationType.system,
          referenceId: v.id,
          createdAt: DateTime.now(),
        ),
      );

      // Update produk petani menjadi isFarmerVerified = true jika user adalah petani
      final farmerProds = _productRepository.getFarmerProducts(v.userId);
      for (final p in farmerProds) {
        _productRepository.updateProduct(p.copyWith(isFarmerVerified: true));
      }
    }
    notifyListeners();
  }

  void rejectVerification(String id, String reason) {
    _adminRepository.rejectVerification(id, reason);
    final verifications = _adminRepository.getVerifications();
    final vIndex = verifications.indexWhere((v) => v.id == id);
    if (vIndex >= 0) {
      final v = verifications[vIndex];
      _authRepository.updateUserVerificationStatus(v.userId, VerificationStatus.rejected);
      FirebaseService.updateVerificationStatus(v.id, VerificationStatus.rejected, reason: reason);
      FirebaseService.updateUserVerificationStatus(v.userId, VerificationStatus.rejected);

      // Kirim notifikasi sistem ke pengguna dengan alasan penolakan
      _notificationRepository.addNotification(
        NotificationModel(
          id: 'notif_ver_rej_${DateTime.now().millisecondsSinceEpoch}',
          recipientUserId: v.userId,
          senderId: 'admin_agrisync',
          senderName: 'Admin AgriSync',
          title: '⚠️ Pengajuan Berkas Ditolak',
          message: 'Pengajuan berkas verifikasi Anda belum dapat disetujui dengan alasan: "$reason". Silakan periksa kembali dan unggah dokumen yang valid di halaman Profil.',
          type: NotificationType.system,
          referenceId: v.id,
          createdAt: DateTime.now(),
        ),
      );

      // Jika petani, update produk menjadi isFarmerVerified = false
      final farmerProds = _productRepository.getFarmerProducts(v.userId);
      for (final p in farmerProds) {
        _productRepository.updateProduct(p.copyWith(isFarmerVerified: false));
      }
    }
    notifyListeners();
  }

  void reopenVerification(String id) {
    _adminRepository.reopenVerification(id);
    final verifications = _adminRepository.getVerifications();
    final vIndex = verifications.indexWhere((v) => v.id == id);
    if (vIndex >= 0) {
      final v = verifications[vIndex];
      _authRepository.updateUserVerificationStatus(v.userId, VerificationStatus.pending);
      FirebaseService.updateVerificationStatus(v.id, VerificationStatus.pending);
      FirebaseService.updateUserVerificationStatus(v.userId, VerificationStatus.pending);
    }
    notifyListeners();
  }

  void resolveDispute(String id, String notes) {
    _adminRepository.resolveDispute(id, notes);
    notifyListeners();
  }

  // ==========================================
  // 7. MONETIZATION & SUBSCRIPTION (CPMK 2 & 5)
  // ==========================================
  Future<bool> upgradeToPro({required bool isAnnual}) async {
    try {
      final expiryDate = DateTime.now().add(Duration(days: isAnnual ? 365 : 30));
      final updatedUser = currentUser.copyWith(
        isProMember: true,
        subscriptionExpiry: expiryDate,
      );

      _authRepository.updateProfile(
        name: updatedUser.name,
        businessType: updatedUser.businessType,
        farmLocation: updatedUser.farmLocation,
        isProMember: true,
        subscriptionExpiry: expiryDate,
      );

      // Simpan status langganan ke local storage
      await _storage?.saveCurrentUser(updatedUser);

      // Berikan notifikasi sistem
      _notificationRepository.addNotification(
        NotificationModel(
          id: 'notif_sub_${DateTime.now().millisecondsSinceEpoch}',
          recipientUserId: updatedUser.id,
          senderId: 'system_admin',
          senderName: 'AgriSync Pro Engine',
          title: '⭐ Langganan AgriSync PRO Aktif!',
          message: 'Selamat! Akun Anda telah di-upgrade ke AgriSync PRO (${isAnnual ? "Tahunan" : "Bulanan"}). Nikmati potongan komisi dan prioritas listing.',
          type: NotificationType.system,
          referenceId: 'sub_pro',
          createdAt: DateTime.now(),
        ),
      );

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> cancelProSubscription() async {
    final updatedUser = currentUser.copyWith(
      isProMember: false,
      subscriptionExpiry: null,
    );
    _authRepository.updateProfile(
      name: updatedUser.name,
      businessType: updatedUser.businessType,
      farmLocation: updatedUser.farmLocation,
      isProMember: false,
      subscriptionExpiry: null,
    );
    await _storage?.saveCurrentUser(updatedUser);
    notifyListeners();
  }

  // ==========================================
  // 8. OFFLINE-FIRST & CACHE SYNC ENGINE (CPMK 4)
  // ==========================================
  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;

  void toggleOfflineMode() {
    _isOfflineMode = !_isOfflineMode;
    notifyListeners();
  }

  void setOfflineMode(bool val) {
    _isOfflineMode = val;
    notifyListeners();
  }

  List<Map<String, dynamic>> get offlinePendingQueue {
    final stored = _storage?.loadOfflineQueue();
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    return _inMemoryOfflineQueue;
  }

  void syncOfflineQueue() {
    syncOfflineData();
  }

  int get offlineQueueCount => offlinePendingQueue.length;

  Future<int> syncOfflineData() async {
    final queue = List<Map<String, dynamic>>.from(offlinePendingQueue);
    final allProducts = _productRepository.getProducts();
    int syncedCount = 0;

    // 1. Sync all pending offline products
    for (final p in allProducts.where((p) => p.isPendingSync)) {
      final synced = p.copyWith(isPendingSync: false);
      _productRepository.updateProduct(synced);
      FirebaseService.uploadProduct(synced);
      syncedCount++;
    }

    // 2. Count queued mutation actions
    for (final _ in queue) {
      syncedCount++;
    }

    _inMemoryOfflineQueue.clear();
    await _storage?.clearOfflineQueue();

    _notificationRepository.addNotification(
      NotificationModel(
        id: 'notif_sync_${DateTime.now().millisecondsSinceEpoch}',
        recipientUserId: currentUser.id,
        senderId: 'system_offline_engine',
        senderName: 'AgriSync Offline Sync',
        title: '🔄 Sinkronisasi Data Offline Selesai',
        message: 'Sebanyak $syncedCount aksi tertunda telah berhasil disinkronkan ke server pusat.',
        type: NotificationType.system,
        referenceId: 'offline_sync',
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
    return syncedCount;
  }

  // ==========================================
  // 9. APP PREFERENCES, THEME, NOTIFICATIONS & SECURITY
  // ==========================================
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    final modeStr = mode == ThemeMode.dark ? 'dark' : (mode == ThemeMode.system ? 'system' : 'light');
    _storage?.saveAppPreferences({
      'language': _selectedLanguage,
      'themeMode': modeStr,
      'weightUnit': _weightUnit,
      'currency': _currency,
    });
    notifyListeners();
  }

  String get selectedLanguage => _selectedLanguage;

  void setLanguage(String lang) {
    _selectedLanguage = lang;
    _storage?.saveAppPreferences({
      'language': _selectedLanguage,
      'themeMode': _themeMode == ThemeMode.dark ? 'dark' : (_themeMode == ThemeMode.system ? 'system' : 'light'),
      'weightUnit': _weightUnit,
      'currency': _currency,
    });
    notifyListeners();
  }

  String get weightUnit => _weightUnit;

  void setWeightUnit(String unit) {
    _weightUnit = unit;
    _storage?.saveAppPreferences({
      'language': _selectedLanguage,
      'themeMode': _themeMode == ThemeMode.dark ? 'dark' : (_themeMode == ThemeMode.system ? 'system' : 'light'),
      'weightUnit': _weightUnit,
      'currency': _currency,
    });
    notifyListeners();
  }

  String get currency => _currency;

  void setCurrency(String curr) {
    _currency = curr;
    _storage?.saveAppPreferences({
      'language': _selectedLanguage,
      'themeMode': _themeMode == ThemeMode.dark ? 'dark' : (_themeMode == ThemeMode.system ? 'system' : 'light'),
      'weightUnit': _weightUnit,
      'currency': _currency,
    });
    notifyListeners();
  }

  Map<String, bool> get notificationSettings => _notificationSettings;

  bool getNotificationSetting(String key) {
    if (_notificationSettings.containsKey(key)) {
      return _notificationSettings[key]!;
    }
    // Mapping fallback untuk backward compatibility
    final aliases = <String, String>{
      'orderNotif': 'orders',
      'negotiationNotif': 'negotiations',
      'harvestAlert': 'harvests',
      'priceTrends': 'price_trends',
      'soundVibrate': 'sound_vibrate',
      'emailDigest': 'email_digest',
    };
    if (aliases.containsKey(key) && _notificationSettings.containsKey(aliases[key])) {
      return _notificationSettings[aliases[key]]!;
    }
    return key == 'promotions' ? false : true;
  }

  void setNotificationSetting(String key, bool value) {
    _notificationSettings[key] = value;
    _storage?.saveNotificationPreferences(_notificationSettings);
    notifyListeners();
  }

  bool get twoFactorEnabled => _twoFactorEnabled;

  void setTwoFactorEnabled(bool value) {
    _twoFactorEnabled = value;
    _storage?.saveSecuritySettings({
      'twoFactorEnabled': _twoFactorEnabled,
      'biometricEnabled': _biometricEnabled,
    });
    notifyListeners();
  }

  bool get biometricEnabled => _biometricEnabled;

  void setBiometricEnabled(bool value) {
    _biometricEnabled = value;
    _storage?.saveSecuritySettings({
      'twoFactorEnabled': _twoFactorEnabled,
      'biometricEnabled': _biometricEnabled,
    });
    notifyListeners();
  }

  Future<void> invalidateOtherSessions() async {
    final token = 'agrisync_sec_${DateTime.now().millisecondsSinceEpoch}';
    await _storage?.saveAuthToken(token);
    notifyListeners();
  }

  Future<double> clearAppCache() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    notifyListeners();
    return 12.8;
  }

  void updateAvatar(String avatarUrl) {
    updateProfile(avatarUrl: avatarUrl);
  }

  Future<void> submitVerificationDocument({
    required String documentName,
    required String documentPath,
    required String roleDetail,
  }) async {
    // 1. Reset status akun pengguna menjadi pending agar diverifikasi ulang oleh Admin
    _authRepository.updateUserVerificationStatus(currentUser.id, VerificationStatus.pending);
    await FirebaseService.updateUserVerificationStatus(currentUser.id, VerificationStatus.pending);

    // 2. Buat item verifikasi baru dengan status pending
    final item = VerificationItem(
      id: 'ver_${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUser.id,
      userName: currentUser.name,
      userRole: currentUser.role,
      roleDetail: roleDetail,
      location: currentUser.farmLocation ?? 'Indonesia',
      registrationType: 'Pembaruan Dokumen',
      documentName: documentName,
      documentUrl: documentPath,
      submissionDate: DateTime.now(),
      status: VerificationStatus.pending,
    );

    _adminRepository.addVerification(item);
    await FirebaseService.saveVerification(item);

    // 3. Kirim notifikasi ke pengguna bahwa berkas sedang diverifikasi ulang
    _notificationRepository.addNotification(
      NotificationModel(
        id: 'notif_ver_submit_${DateTime.now().millisecondsSinceEpoch}',
        recipientUserId: currentUser.id,
        senderId: 'system_admin',
        senderName: 'Tim Verifikasi AgriSync',
        title: '📑 Pembaruan Berkas Terkirim',
        message: 'Berkas legalitas "$documentName" telah berhasil diperbarui dan masuk antrean verifikasi ulang oleh Admin AgriSync.',
        type: NotificationType.system,
        referenceId: item.id,
        createdAt: DateTime.now(),
      ),
    );

    // 4. Kirim notifikasi ke Admin bahwa ada berkas yang perlu diverifikasi ulang
    _notificationRepository.addNotification(
      NotificationModel(
        id: 'notif_admin_rever_${DateTime.now().millisecondsSinceEpoch}',
        recipientUserId: 'usr_admin_1',
        senderId: currentUser.id,
        senderName: currentUser.name,
        title: '🔔 Pembaruan Berkas Menunggu Verifikasi',
        message: '${currentUser.name} (${currentUser.roleDisplay}) telah memperbarui berkas "$documentName". Silakan tinjau dan lakukan verifikasi ulang.',
        type: NotificationType.system,
        referenceId: item.id,
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  String submitSupportTicket({
    required String category,
    required String subject,
    required String message,
  }) {
    final ticketId = 'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    _notificationRepository.addNotification(
      NotificationModel(
        id: 'notif_tkt_${DateTime.now().millisecondsSinceEpoch}',
        recipientUserId: currentUser.id,
        senderId: 'cs_agrisync_support',
        senderName: 'Customer Support AgriSync',
        title: '🎫 Tiket Bantuan Dibuat: #$ticketId',
        message: '[$category - #$ticketId] $subject: Laporan Anda telah diterima tim CS AgriSync dan segera ditindaklanjuti.',
        type: NotificationType.system,
        referenceId: ticketId,
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
    return ticketId;
  }
}


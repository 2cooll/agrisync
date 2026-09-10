import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/chat_model.dart';
import '../models/order_model.dart';
import '../models/verification_model.dart';
import '../models/notification_model.dart';
import '../mock_data.dart';

class LocalStorageService {
  static const String _keyCurrentUser = 'agrisync_current_user';
  static const String _keyIsLoggedIn = 'agrisync_is_logged_in';
  static const String _keyProducts = 'agrisync_products';
  static const String _keyChatThreads = 'agrisync_chat_threads';
  static const String _keyOrders = 'agrisync_orders';
  static const String _keyVerifications = 'agrisync_verifications';
  static const String _keyDisputes = 'agrisync_disputes';
  static const String _keyNotifications = 'agrisync_notifications';
  static const String _keyFavorites = 'agrisync_favorites';
  static const String _keyAuthToken = 'agrisync_secure_auth_token';
  static const String _keyOfflineQueue = 'agrisync_offline_sync_queue';
  static const String _keyRegisteredUsers = 'agrisync_registered_users';
  static const String _keyGoogleRoleBindings = 'agrisync_google_role_bindings';
  static const String _keyUserCredentials = 'agrisync_user_credentials';
  static const String _keyNotificationPrefs = 'agrisync_notification_preferences';
  static const String _keyAppPrefs = 'agrisync_app_preferences';
  static const String _keySecuritySettings = 'agrisync_security_settings';

  final SharedPreferences? _prefs;

  LocalStorageService({SharedPreferences? prefs}) : _prefs = prefs;

  static Future<LocalStorageService> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return LocalStorageService(prefs: prefs);
    } catch (_) {
      return LocalStorageService(prefs: null);
    }
  }

  // --- REGISTERED USERS & GOOGLE ROLE BINDING REGISTRY ---
  List<UserModel> loadRegisteredUsers() {
    try {
      final raw = _prefs?.getString(_keyRegisteredUsers);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [
      MockData.defaultPebisnis.copyWith(email: 'pebisnis@agrisync.id'),
      MockData.defaultPetani.copyWith(email: 'petani@agrisync.id'),
      MockData.defaultAdmin.copyWith(email: 'admin@agrisync.id'),
    ];
  }

  Future<void> saveRegisteredUser(UserModel user, {String? password}) async {
    try {
      final users = loadRegisteredUsers();
      final index = users.indexWhere((u) =>
          u.id == user.id ||
          (user.email != null && u.email?.trim().toLowerCase() == user.email!.trim().toLowerCase()) ||
          (user.phone.isNotEmpty && u.phone.trim() == user.phone.trim()));
      if (index >= 0) {
        users[index] = user;
      } else {
        users.add(user);
      }
      final jsonList = users.map((u) => u.toJson()).toList();
      await _prefs?.setString(_keyRegisteredUsers, jsonEncode(jsonList));

      if (password != null && (user.email != null || user.phone.isNotEmpty)) {
        final creds = loadUserCredentials();
        if (user.email != null) creds[user.email!.trim().toLowerCase()] = password;
        if (user.phone.isNotEmpty) creds[user.phone.trim()] = password;
        await _prefs?.setString(_keyUserCredentials, jsonEncode(creds));
      }
    } catch (_) {}
  }

  Future<void> updateUserVerificationStatus(String userId, VerificationStatus status) async {
    try {
      final users = loadRegisteredUsers();
      final index = users.indexWhere((u) => u.id == userId);
      if (index >= 0) {
        users[index] = users[index].copyWith(verificationStatus: status);
        final jsonList = users.map((u) => u.toJson()).toList();
        await _prefs?.setString(_keyRegisteredUsers, jsonEncode(jsonList));
      }
      final cur = loadCurrentUser();
      if (cur.id == userId) {
        saveCurrentUser(cur.copyWith(verificationStatus: status));
      }
    } catch (_) {}
  }

  /// Hapus akun pengguna dan seluruh data turunannya dari Local Storage (Cascade Delete)
  Future<void> deleteRegisteredUser(String userId) async {
    try {
      final users = loadRegisteredUsers();
      UserModel? target;
      try {
        target = users.firstWhere((u) => u.id == userId);
      } catch (_) {
        target = null;
      }
      users.removeWhere((u) => u.id == userId);
      final jsonList = users.map((u) => u.toJson()).toList();
      await _prefs?.setString(_keyRegisteredUsers, jsonEncode(jsonList));

      // Hapus kredensial
      if (target != null) {
        final creds = loadUserCredentials();
        if (target.email != null) creds.remove(target.email!.trim().toLowerCase());
        if (target.phone.isNotEmpty) creds.remove(target.phone.trim());
        await _prefs?.setString(_keyUserCredentials, jsonEncode(creds));
      }

      // Hapus semua produk milik pengguna ini
      await deleteProductsByFarmer(userId);

      // Hapus semua berkas verifikasi milik pengguna ini
      await deleteVerificationsByUser(userId);
    } catch (_) {}
  }

  /// Hapus semua produk milik petani tertentu dari Local Storage
  Future<void> deleteProductsByFarmer(String farmerId) async {
    try {
      final prods = loadProducts();
      prods.removeWhere((p) => p.farmerId == farmerId);
      await saveProducts(prods);
    } catch (_) {}
  }

  /// Hapus semua berkas verifikasi milik pengguna tertentu dari Local Storage
  Future<void> deleteVerificationsByUser(String userId) async {
    try {
      final vers = loadVerifications();
      vers.removeWhere((v) => v.userId == userId);
      await saveVerifications(vers);
    } catch (_) {}
  }

  Map<String, String> loadUserCredentials() {
    try {
      final raw = _prefs?.getString(_keyUserCredentials);
      if (raw != null) {
        return Map<String, String>.from(jsonDecode(raw) as Map);
      }
    } catch (_) {}
    return {
      '081234567890': 'password123',
      '081987654321': 'password123',
      '08111222333': 'password123',
      'pebisnis@agrisync.id': 'password123',
      'petani@agrisync.id': 'password123',
      'admin@agrisync.id': 'password123',
    };
  }

  Future<void> updateUserPassword(String identifier, String newPassword) async {
    try {
      final creds = loadUserCredentials();
      final clean = identifier.trim().toLowerCase();
      creds[clean] = newPassword;
      final user = findUserByEmailOrPhone(identifier);
      if (user != null) {
        if (user.email != null) creds[user.email!.trim().toLowerCase()] = newPassword;
        if (user.phone.isNotEmpty) creds[user.phone.trim()] = newPassword;
      }
      await _prefs?.setString(_keyUserCredentials, jsonEncode(creds));
    } catch (_) {}
  }

  String? getUserPassword(String identifier) {
    final clean = identifier.trim().toLowerCase();
    final creds = loadUserCredentials();
    if (creds.containsKey(clean)) return creds[clean];
    final user = findUserByEmailOrPhone(identifier);
    if (user != null) {
      if (user.email != null && creds.containsKey(user.email!.trim().toLowerCase())) {
        return creds[user.email!.trim().toLowerCase()];
      }
      if (user.phone.isNotEmpty && creds.containsKey(user.phone.trim())) {
        return creds[user.phone.trim()];
      }
      if (user.phone.isNotEmpty && creds.containsKey(user.phone.trim().toLowerCase())) {
        return creds[user.phone.trim().toLowerCase()];
      }
    }
    return null;
  }

  UserModel? findUserByEmailOrPhone(String query) {
    final clean = query.trim().toLowerCase();
    final users = loadRegisteredUsers();
    for (final u in users) {
      if (u.email?.trim().toLowerCase() == clean || u.phone.trim().toLowerCase() == clean) {
        return u;
      }
    }
    return null;
  }

  UserModel? findUserById(String id) {
    final users = loadRegisteredUsers();
    for (final u in users) {
      if (u.id == id) {
        return u;
      }
    }
    return null;
  }

  // --- GOOGLE EMAIL ROLE BINDING (1 GOOGLE ACCOUNT = 1 ROLE) ---
  Map<String, String> loadGoogleRoleBindings() {
    try {
      final raw = _prefs?.getString(_keyGoogleRoleBindings);
      if (raw != null) {
        return Map<String, String>.from(jsonDecode(raw) as Map);
      }
    } catch (_) {}
    return {};
  }

  Future<void> saveGoogleRoleBinding(String email, String roleName) async {
    try {
      final bindings = loadGoogleRoleBindings();
      bindings[email.trim().toLowerCase()] = roleName;
      await _prefs?.setString(_keyGoogleRoleBindings, jsonEncode(bindings));
    } catch (_) {}
  }

  String? getRoleForGoogleEmail(String email) {
    final bindings = loadGoogleRoleBindings();
    return bindings[email.trim().toLowerCase()];
  }

  // --- SECURE AUTH TOKEN & CREDENTIALS ---
  Future<void> saveAuthToken(String token) async {
    try {
      // In production with flutter_secure_storage or base64 masked local key
      final encoded = base64Encode(utf8.encode(token));
      await _prefs?.setString(_keyAuthToken, encoded);
    } catch (_) {}
  }

  String? loadAuthToken() {
    try {
      final raw = _prefs?.getString(_keyAuthToken);
      if (raw != null) {
        return utf8.decode(base64Decode(raw));
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearAuthToken() async {
    try {
      await _prefs?.remove(_keyAuthToken);
    } catch (_) {}
  }

  // --- OFFLINE SYNC QUEUE ---
  List<Map<String, dynamic>> loadOfflineQueue() {
    try {
      final raw = _prefs?.getString(_keyOfflineQueue);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> saveOfflineQueue(List<Map<String, dynamic>> queue) async {
    try {
      await _prefs?.setString(_keyOfflineQueue, jsonEncode(queue));
    } catch (_) {}
  }

  Future<void> addToOfflineQueue(Map<String, dynamic> action) async {
    final current = loadOfflineQueue();
    current.add({
      ...action,
      'queuedAt': DateTime.now().toIso8601String(),
    });
    await saveOfflineQueue(current);
  }

  Future<void> clearOfflineQueue() async {
    try {
      await _prefs?.remove(_keyOfflineQueue);
    } catch (_) {}
  }

  // --- CURRENT USER & AUTH ---
  UserModel loadCurrentUser() {
    try {
      final raw = _prefs?.getString(_keyCurrentUser);
      if (raw != null) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return UserModel.fromJson(map);
      }
    } catch (_) {}
    return MockData.defaultPebisnis;
  }

  Future<void> saveCurrentUser(UserModel user) async {
    try {
      await _prefs?.setString(_keyCurrentUser, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  bool loadIsLoggedIn() {
    return _prefs?.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> saveIsLoggedIn(bool isLoggedIn) async {
    try {
      await _prefs?.setBool(_keyIsLoggedIn, isLoggedIn);
    } catch (_) {}
  }

  // --- PRODUCTS ---
  List<ProductModel> loadProducts() {
    try {
      final raw = _prefs?.getString(_keyProducts);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return MockData.getInitialProducts();
  }

  Future<void> saveProducts(List<ProductModel> products) async {
    try {
      final jsonList = products.map((p) => p.toJson()).toList();
      await _prefs?.setString(_keyProducts, jsonEncode(jsonList));
    } catch (_) {}
  }

  // --- CHAT THREADS ---
  List<ChatThread> loadChatThreads() {
    try {
      final raw = _prefs?.getString(_keyChatThreads);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.map((e) => ChatThread.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return MockData.getInitialChatThreads();
  }

  Future<void> saveChatThreads(List<ChatThread> threads) async {
    try {
      final jsonList = threads.map((t) => t.toJson()).toList();
      await _prefs?.setString(_keyChatThreads, jsonEncode(jsonList));
    } catch (_) {}
  }

  // --- ORDERS ---
  List<OrderModel> loadOrders() {
    try {
      final raw = _prefs?.getString(_keyOrders);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return MockData.getInitialOrders();
  }

  Future<void> saveOrders(List<OrderModel> orders) async {
    try {
      final jsonList = orders.map((o) => o.toJson()).toList();
      await _prefs?.setString(_keyOrders, jsonEncode(jsonList));
    } catch (_) {}
  }

  // --- VERIFICATIONS & DISPUTES ---
  List<VerificationItem> loadVerifications() {
    try {
      final raw = _prefs?.getString(_keyVerifications);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.map((e) => VerificationItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return MockData.getInitialVerifications();
  }

  Future<void> saveVerifications(List<VerificationItem> items) async {
    try {
      final jsonList = items.map((v) => v.toJson()).toList();
      await _prefs?.setString(_keyVerifications, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<DisputeItem> loadDisputes() {
    try {
      final raw = _prefs?.getString(_keyDisputes);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.map((e) => DisputeItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return MockData.getInitialDisputes();
  }

  Future<void> saveDisputes(List<DisputeItem> disputes) async {
    try {
      final jsonList = disputes.map((d) => d.toJson()).toList();
      await _prefs?.setString(_keyDisputes, jsonEncode(jsonList));
    } catch (_) {}
  }

  // --- NOTIFICATIONS ---
  List<NotificationModel> loadNotifications() {
    try {
      final raw = _prefs?.getString(_keyNotifications);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return MockData.getInitialNotifications();
  }

  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    try {
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await _prefs?.setString(_keyNotifications, jsonEncode(jsonList));
    } catch (_) {}
  }

  // --- FAVORITES ---
  List<String> loadFavorites() {
    try {
      final raw = _prefs?.getStringList(_keyFavorites);
      if (raw != null) return raw;
    } catch (_) {}
    return ['prod_1', 'prod_4'];
  }

  Future<void> saveFavorites(List<String> favorites) async {
    try {
      await _prefs?.setStringList(_keyFavorites, favorites);
    } catch (_) {}
  }

  // --- NOTIFICATION PREFERENCES ---
  Map<String, bool> loadNotificationPreferences() {
    try {
      final raw = _prefs?.getString(_keyNotificationPrefs);
      if (raw != null) {
        return Map<String, bool>.from(jsonDecode(raw) as Map);
      }
    } catch (_) {}
    return {
      'negotiations': true,
      'orders': true,
      'harvests': true,
      'price_trends': true,
      'promotions': false,
      'sound_vibrate': true,
      'email_digest': true,
    };
  }

  Future<void> saveNotificationPreferences(Map<String, bool> prefs) async {
    try {
      await _prefs?.setString(_keyNotificationPrefs, jsonEncode(prefs));
    } catch (_) {}
  }

  // --- APP & REGIONAL PREFERENCES ---
  Map<String, String> loadAppPreferences() {
    try {
      final raw = _prefs?.getString(_keyAppPrefs);
      if (raw != null) {
        return Map<String, String>.from(jsonDecode(raw) as Map);
      }
    } catch (_) {}
    return {
      'language': 'Bahasa Indonesia',
      'themeMode': 'light', // 'light', 'dark', 'system'
      'weightUnit': 'Kilogram (kg)',
      'currency': 'IDR (Rupiah Indonesia - Rp)',
    };
  }

  Future<void> saveAppPreferences(Map<String, String> prefs) async {
    try {
      await _prefs?.setString(_keyAppPrefs, jsonEncode(prefs));
    } catch (_) {}
  }

  // --- SECURITY SETTINGS ---
  Map<String, bool> loadSecuritySettings() {
    try {
      final raw = _prefs?.getString(_keySecuritySettings);
      if (raw != null) {
        return Map<String, bool>.from(jsonDecode(raw) as Map);
      }
    } catch (_) {}
    return {
      'twoFactorEnabled': true,
      'biometricEnabled': false,
    };
  }

  Future<void> saveSecuritySettings(Map<String, bool> settings) async {
    try {
      await _prefs?.setString(_keySecuritySettings, jsonEncode(settings));
    } catch (_) {}
  }

  Future<void> updateUserAvatar(String userId, String avatarUrl) async {
    try {
      final users = loadRegisteredUsers();
      final index = users.indexWhere((u) => u.id == userId);
      if (index >= 0) {
        users[index] = users[index].copyWith(avatarUrl: avatarUrl);
        await _prefs?.setString(_keyRegisteredUsers, jsonEncode(users.map((u) => u.toJson()).toList()));
      }
      final current = loadCurrentUser();
      if (current.id == userId) {
        await saveCurrentUser(current.copyWith(avatarUrl: avatarUrl));
      }
    } catch (_) {}
  }
}


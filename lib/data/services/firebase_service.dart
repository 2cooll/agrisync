import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/verification_model.dart';
import '../models/chat_model.dart';
import '../models/review_model.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inisialisasi Firebase secara aman untuk Web, Android, & iOS
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _isInitialized = true;
        debugPrint('🔥 [AgriSync] Firebase successfully initialized on platform: ${defaultTargetPlatform.name}');
      }
    } catch (e) {
      debugPrint('⚠️ [AgriSync] Firebase initialization note: $e (Falling back to local storage offline mode)');
    }
  }

  /// Mengecek apakah API Key Firebase yang dikonfigurasi adalah API Key asli atau masih placeholder demo
  static bool get hasValidApiKey {
    try {
      final key = DefaultFirebaseOptions.currentPlatform.apiKey;
      return key.isNotEmpty && !key.contains('Placeholder_Demo');
    } catch (_) {
      return false;
    }
  }

  // --- FIREBASE AUTHENTICATION ---
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static User? get currentFirebaseUser => _isInitialized ? auth.currentUser : null;

  static Stream<User?> get authStateChanges =>
      _isInitialized ? auth.authStateChanges() : Stream<User?>.value(null);

  /// Registrasi akun baru di Firebase Auth & Cloud Firestore
  static Future<UserModel?> signUpWithEmailPassword({
    required String email,
    required String password,
    required UserModel userProfile,
  }) async {
    UserModel finalUser = userProfile.copyWith(email: email);
    if (_isInitialized) {
      if (hasValidApiKey) {
        try {
          final credential = await auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

          if (credential.user != null) {
            try {
              await credential.user!.sendEmailVerification();
              debugPrint('✉️ [FirebaseAuth] Email verification link sent successfully to $email');
            } catch (verErr) {
              debugPrint('⚠️ [FirebaseAuth.sendEmailVerification] Note: $verErr');
            }
            finalUser = finalUser.copyWith(id: credential.user!.uid);
            await saveUserProfile(finalUser);
          }
        } catch (e) {
          debugPrint('⚠️ [FirebaseAuth] SignUp Note: $e (Falling back to local Firestore save)');
          await saveUserProfile(finalUser);
        }
      } else {
        debugPrint('ℹ️ [FirebaseService] Menggunakan akun lokal/demo (API Key di firebase_options.dart masih berupa placeholder demo).');
        await saveUserProfile(finalUser);
      }
    }
    return finalUser;
  }

  /// Kirim ulang email verifikasi ke pengguna Firebase yang sedang aktif
  static Future<bool> sendEmailVerificationToCurrentUser() async {
    if (!_isInitialized) return false;
    try {
      final user = auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('✉️ [FirebaseService] Verification email resent to ${user.email}');
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [FirebaseService.sendEmailVerificationToCurrentUser] Error: $e');
    }
    return false;
  }

  /// Periksa apakah email pengguna saat ini sudah diklik verifikasi di Gmail
  static Future<bool> checkEmailVerified() async {
    if (!_isInitialized) return false;
    try {
      final user = auth.currentUser;
      if (user != null) {
        await user.reload();
        return auth.currentUser?.emailVerified ?? false;
      }
    } catch (e) {
      debugPrint('⚠️ [FirebaseService.checkEmailVerified] Error: $e');
    }
    return false;
  }

  /// Login akun Firebase Auth & Ambil Profil dari Firestore
  static Future<UserModel?> signInWithEmailPassword({
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) async {
    if (!_isInitialized) return null;
    final cleanInput = emailOrPhone.trim();
    final cleanEmail = cleanInput.toLowerCase();

    try {
      if (hasValidApiKey && cleanInput.contains('@')) {
        try {
          final cred = await auth.signInWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
          if (cred.user != null) {
            final doc = await usersCollection.doc(cred.user!.uid).get();
            if (doc.exists) {
              final user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
              debugPrint('🔥 [FirebaseAuth] Signed in successfully: ${user.name}');
              return user;
            }
          }
        } catch (authErr) {
          debugPrint('⚠️ [FirebaseAuth.signInWithEmailAndPassword] Note: $authErr');
        }
      }

      // Query by email in Firestore users collection
      if (cleanInput.contains('@')) {
        final querySnapshot = await usersCollection
            .where('email', isEqualTo: cleanEmail)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
          final user = UserModel.fromJson(data);
          debugPrint('🔥 [Firestore] User found in users collection by email: ${user.name}');
          return user;
        }
      }

      // Query by phone in Firestore users collection
      final phoneQuery = await usersCollection
          .where('phone', isEqualTo: cleanInput)
          .limit(1)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        final data = phoneQuery.docs.first.data() as Map<String, dynamic>;
        final user = UserModel.fromJson(data);
        debugPrint('🔥 [Firestore] User found in users collection by phone: ${user.name}');
        return user;
      }
    } catch (e) {
      debugPrint('⚠️ [FirebaseService.signInWithEmailPassword] Note: $e');
    }
    return null;
  }

  /// Logout dari Firebase Auth
  static Future<void> signOut() async {
    if (!_isInitialized) return;
    try {
      await auth.signOut();
    } catch (e) {
      debugPrint('❌ [FirebaseAuth] SignOut Error: $e');
    }
  }

  /// Update kata sandi akun Firebase Auth
  static Future<void> updatePassword(String newPassword) async {
    if (!_isInitialized) return;
    try {
      if (hasValidApiKey && auth.currentUser != null) {
        await auth.currentUser!.updatePassword(newPassword);
      }
    } catch (e) {
      debugPrint('⚠️ [FirebaseAuth] updatePassword: $e');
    }
  }

  /// Reset kata sandi pengguna berdasarkan email/phone
  static Future<void> resetPasswordForUser({
    required String emailOrPhone,
    required String newPassword,
  }) async {
    if (!_isInitialized) return;
    try {
      final clean = emailOrPhone.trim().toLowerCase();
      if (clean.contains('@')) {
        await sendPasswordResetEmail(clean);
      }
    } catch (e) {
      debugPrint('⚠️ [FirebaseService.resetPasswordForUser] Note: $e');
    }
  }

  /// Kirim email reset kata sandi resmi Firebase Auth
  static Future<void> sendPasswordResetEmail(String email) async {
    if (!_isInitialized) return;
    try {
      if (hasValidApiKey) {
        await auth.sendPasswordResetEmail(email: email.trim());
        debugPrint('🔥 [FirebaseAuth] Password reset email sent to: $email');
      }
    } catch (e) {
      debugPrint('⚠️ [FirebaseAuth.sendPasswordResetEmail] Note: $e');
    }
  }

  /// Login / Daftar dengan Akun Google + Penegakan 1 Akun Google = 1 Role
  static Future<UserModel> signInWithGoogle({
    required UserRole role,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    String effectiveEmail = email?.trim().toLowerCase() ?? 'user.${role.name}@gmail.com';
    String effectiveName = displayName ?? (role == UserRole.petani ? 'Budi Santoso (Google)' : 'Resto Berkah Google');
    String effectiveId = 'usr_google_${DateTime.now().millisecondsSinceEpoch}';

    if (_isInitialized) {
      try {
        if (hasValidApiKey && kIsWeb) {
          // Google Auth Provider for Web popup
          final googleProvider = GoogleAuthProvider();
          googleProvider.addScope('email');
          googleProvider.addScope('profile');
          try {
            final userCred = await auth.signInWithPopup(googleProvider);
            if (userCred.user != null) {
              effectiveEmail = userCred.user!.email?.toLowerCase() ?? effectiveEmail;
              effectiveName = userCred.user!.displayName ?? effectiveName;
              effectiveId = userCred.user!.uid;
            }
          } catch (webAuthErr) {
            debugPrint('⚠️ [GoogleAuthProvider Web Popup]: $webAuthErr (Using provided/selected Google account)');
          }
        }

        // Cek apakah akun Google (email) ini sudah terdaftar di Firestore
        final existingQuery = await usersCollection
            .where('email', isEqualTo: effectiveEmail)
            .limit(1)
            .get();

        if (existingQuery.docs.isNotEmpty) {
          final existingData = existingQuery.docs.first.data() as Map<String, dynamic>;
          final existingUser = UserModel.fromJson(existingData);

          // ATURAN 1 AKUN GOOGLE = 1 ROLE:
          if (existingUser.role != role) {
            throw Exception(
              'Akun Google ini ($effectiveEmail) sudah terdaftar sebagai ${existingUser.roleDisplay}.\n\n'
              'Satu akun Google hanya dapat digunakan untuk 1 peran. Silakan masuk sesuai peran Anda yang sudah terdaftar.',
            );
          }

          debugPrint('✅ [Google Auth] Existing user found matching role: ${existingUser.name}');
          return existingUser;
        }
      } catch (e) {
        if (e.toString().contains('Satu akun Google hanya dapat digunakan')) {
          rethrow;
        }
        debugPrint('⚠️ [Firebase] Google Sign-in note: $e');
      }
    }

    // Akun baru terdaftar dengan peran ini
    final newUser = UserModel(
      id: effectiveId,
      name: effectiveName,
      phone: effectiveEmail,
      email: effectiveEmail,
      role: role,
      farmLocation: role == UserRole.petani ? 'Batu, Jawa Timur' : null,
      businessType: role == UserRole.pebisnis ? 'Kuliner & Restoran' : null,
      documentPath: 'Google_Verified_ID',
      verificationStatus: VerificationStatus.verified,
      joinedDate: DateTime.now(),
      avatarUrl: photoUrl ?? 'https://placehold.co/100x100/34A853/ffffff?text=G',
    );

    if (_isInitialized) {
      try {
        await saveUserProfile(newUser);
      } catch (e) {
        debugPrint('⚠️ [Firebase] Failed to save Google user to Firestore: $e');
      }
    }

    return newUser;
  }

  // --- CLOUD FIRESTORE COLLECTIONS ---
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static CollectionReference get usersCollection => firestore.collection('users');
  static CollectionReference get productsCollection => firestore.collection('products');
  static CollectionReference get ordersCollection => firestore.collection('orders');
  static CollectionReference get notificationsCollection => firestore.collection('notifications');
  static CollectionReference get verificationsCollection => firestore.collection('verifications');
  static CollectionReference get chatsCollection => firestore.collection('chats');
  static CollectionReference get reviewsCollection => firestore.collection('reviews');
  static CollectionReference get disputesCollection => firestore.collection('disputes');

  /// Simpan berkas verifikasi ke Cloud Firestore
  static Future<void> saveVerification(VerificationItem item) async {
    if (!_isInitialized) return;
    try {
      await verificationsCollection.doc(item.id).set(item.toJson(), SetOptions(merge: true));
      debugPrint('✅ [Firestore] Verification synced: ${item.id} (${item.userName})');
    } catch (e) {
      debugPrint('❌ [Firestore] saveVerification Error: $e');
    }
  }

  /// Update status verifikasi di Cloud Firestore
  static Future<void> updateVerificationStatus(String verificationId, VerificationStatus status, {String? reason}) async {
    if (!_isInitialized) return;
    try {
      final data = {
        'status': status.name,
        if (reason != null) 'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await verificationsCollection.doc(verificationId).set(data, SetOptions(merge: true));
      debugPrint('✅ [Firestore] Verification status updated: $verificationId -> ${status.name}');
    } catch (e) {
      debugPrint('❌ [Firestore] updateVerificationStatus Error: $e');
    }
  }

  /// Update status verifikasi pengguna di Cloud Firestore
  static Future<void> updateUserVerificationStatus(String userId, VerificationStatus status) async {
    if (!_isInitialized) return;
    try {
      await usersCollection.doc(userId).set({
        'verificationStatus': status.name,
      }, SetOptions(merge: true));
      debugPrint('✅ [Firestore] User verification status updated: $userId -> ${status.name}');
    } catch (e) {
      debugPrint('❌ [Firestore] updateUserVerificationStatus Error: $e');
    }
  }

  /// Simpan profil pengguna ke Cloud Firestore
  static Future<void> saveUserProfile(UserModel user) async {
    if (!_isInitialized) return;
    try {
      await usersCollection.doc(user.id).set(user.toJson(), SetOptions(merge: true));
      debugPrint('✅ [Firestore] User profile synced successfully: ${user.id} (${user.name})');
    } catch (e) {
      debugPrint('❌ [Firestore] saveUserProfile Error: $e');
    }
  }

  /// Hapus akun pengguna beserta seluruh data turunannya secara otomatis (Cascade Delete):
  /// 1. Profil Pengguna di usersCollection
  /// 2. Seluruh Produk Hasil Panen pengguna di productsCollection
  /// 3. Berkas Verifikasi pengguna di verificationsCollection
  /// 4. Akun Firebase Authentication jika pengguna yang sedang login
  static Future<void> deleteUserAccountCascade(String userId, {String? userPhone, String? userEmail}) async {
    if (!_isInitialized) return;
    try {
      // 1. Hapus dokumen profil dari usersCollection
      await usersCollection.doc(userId).delete();
      debugPrint('✅ [Firestore Cascade] User profile deleted: $userId');

      // 2. Hapus seluruh produk milik pengguna ini dari productsCollection
      final prodQuery = await productsCollection.where('farmerId', isEqualTo: userId).get();
      for (final doc in prodQuery.docs) {
        await productsCollection.doc(doc.id).delete();
        debugPrint('✅ [Firestore Cascade] Product deleted: ${doc.id}');
      }

      // 3. Hapus seluruh berkas verifikasi milik pengguna ini
      final verQuery = await verificationsCollection.where('userId', isEqualTo: userId).get();
      for (final doc in verQuery.docs) {
        await verificationsCollection.doc(doc.id).delete();
        debugPrint('✅ [Firestore Cascade] Verification deleted: ${doc.id}');
      }

      // 4. Jika user sedang aktif di Firebase Auth, hapus akun autentikasinya
      final currentFbUser = auth.currentUser;
      if (currentFbUser != null && (currentFbUser.uid == userId || currentFbUser.email == userEmail)) {
        try {
          await currentFbUser.delete();
          debugPrint('✅ [FirebaseAuth] User authentication deleted: $userId');
        } catch (authErr) {
          debugPrint('⚠️ [FirebaseAuth] delete user notice: $authErr');
        }
      }
    } catch (e) {
      debugPrint('❌ [Firestore] deleteUserAccountCascade Error: $e');
    }
  }

  /// Sinkronkan produk hasil panen ke Cloud Firestore (Real-Time)
  static Future<void> uploadProduct(ProductModel product) async {
    if (!_isInitialized) return;
    try {
      await productsCollection.doc(product.id).set(product.toJson(), SetOptions(merge: true));
      debugPrint('✅ [Firestore] Product synced successfully: ${product.id} (${product.title})');
    } catch (e) {
      debugPrint('❌ [Firestore] uploadProduct Error: $e');
    }
  }

  /// Hapus produk dari Cloud Firestore
  static Future<void> deleteProduct(String id) async {
    if (!_isInitialized) return;
    try {
      await productsCollection.doc(id).delete();
      debugPrint('✅ [Firestore] Product deleted: $id');
    } catch (e) {
      debugPrint('❌ [Firestore] deleteProduct Error: $e');
    }
  }

  /// Ambil seluruh produk dari Cloud Firestore secara one-time
  static Future<List<ProductModel>> fetchProductsOnce() async {
    if (!_isInitialized) return [];
    try {
      final snapshot = await productsCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('⚠️ [Firestore] fetchProductsOnce note: $e');
      return [];
    }
  }

  /// Real-Time stream produk panen dari Cloud Firestore
  static Stream<List<ProductModel>> streamProducts() {
    if (!_isInitialized) return const Stream.empty();
    return productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel.fromJson(data);
      }).toList();
    });
  }

  /// Simpan pesanan transaksi ke Cloud Firestore
  static Future<void> createOrder(OrderModel order) async {
    if (!_isInitialized) return;
    try {
      await ordersCollection.doc(order.id).set(order.toJson(), SetOptions(merge: true));
      debugPrint('✅ [Firestore] Order synced successfully: ${order.id} (${order.orderNumber})');
    } catch (e) {
      debugPrint('❌ [Firestore] createOrder Error: $e');
    }
  }

  /// Simpan thread chat dan negosiasi ke Cloud Firestore
  static Future<void> saveChatThread(ChatThread thread) async {
    if (!_isInitialized) return;
    try {
      await chatsCollection.doc(thread.id).set(thread.toJson(), SetOptions(merge: true));
      debugPrint('✅ [Firestore] Chat thread synced: ${thread.id}');
    } catch (e) {
      debugPrint('❌ [Firestore] saveChatThread Error: $e');
    }
  }

  /// Simpan ulasan dan rating produk ke Cloud Firestore
  static Future<void> saveReview(ReviewItem review) async {
    if (!_isInitialized) return;
    try {
      await reviewsCollection.doc(review.id).set(review.toJson(), SetOptions(merge: true));
      debugPrint('✅ [Firestore] Review synced: ${review.id}');
    } catch (e) {
      debugPrint('❌ [Firestore] saveReview Error: $e');
    }
  }

  /// Simpan laporan sengketa (dispute) ke Cloud Firestore
  static Future<void> saveDispute(Map<String, dynamic> disputeJson) async {
    if (!_isInitialized) return;
    try {
      final disputeId = disputeJson['id'] ?? 'disp_${DateTime.now().millisecondsSinceEpoch}';
      await disputesCollection.doc(disputeId).set(disputeJson, SetOptions(merge: true));
      debugPrint('✅ [Firestore] Dispute synced: $disputeId');
    } catch (e) {
      debugPrint('❌ [Firestore] saveDispute Error: $e');
    }
  }

  /// Simpan notifikasi ke Cloud Firestore
  static Future<void> saveNotification(Map<String, dynamic> notificationJson) async {
    if (!_isInitialized) return;
    try {
      final notifId = notificationJson['id'] ?? 'notif_${DateTime.now().millisecondsSinceEpoch}';
      await notificationsCollection.doc(notifId).set(notificationJson, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ [Firestore] saveNotification Error: $e');
    }
  }
}

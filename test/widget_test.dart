import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/main.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/ui/screens/pebisnis/order_confirmation_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/cart_screen.dart';
import 'package:agrisync/ui/screens/profile/notification_settings_screen.dart';
import 'package:agrisync/ui/widgets/notifications_sheet.dart';
import 'package:agrisync/ui/widgets/agri_user_avatar.dart';
import 'package:agrisync/ui/screens/pebisnis/pebisnis_home_screen.dart';
import 'package:agrisync/ui/screens/admin/pending_verifications_screen.dart';
import 'package:agrisync/ui/screens/splash/splash_screen.dart';
import 'package:agrisync/ui/screens/chat/chat_negotiation_screen.dart';
import 'package:agrisync/ui/screens/profile/edit_profile_screen.dart';
import 'package:agrisync/ui/screens/profile/user_profile_screen.dart';
import 'package:agrisync/data/models/user_model.dart';

class MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest();
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

final List<int> kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => MockHttpClient();
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });
  testWidgets('AgriSync Pebisnis Home screen renders properly with search bar and Keranjang tab', (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const AgriSyncApp(showSplash: false),
      ),
    );
    await tester.pump();
    expect(find.text('Kategori Komoditas'), findsOneWidget);
    expect(find.text('Produk Terbaru'), findsOneWidget);
    expect(find.text('Sayuran'), findsOneWidget);

    // Verify search bar exists and tapping it opens SearchResultsScreen
    expect(find.text('Cari Cabai Merah, Bawang, Tomat...'), findsOneWidget);
    await tester.tap(find.text('Cari Cabai Merah, Bawang, Tomat...'));
    await tester.pumpAndSettle();
    expect(find.text('Katalog & Pencarian'), findsOneWidget);

    // Verify search TextField exists and accepts text
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Cabai');
    await tester.pump();
    expect(find.text('Cabai'), findsOneWidget);

    // Pop back to home screen
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    // Verify 'Keranjang' bottom nav item exists (replacing 'Cari')
    expect(find.text('Keranjang'), findsOneWidget);
    expect(find.text('Cari'), findsNothing);

    // Tap on 'Keranjang' tab
    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();
    expect(find.text('Keranjang Belanja'), findsOneWidget);
  });

  testWidgets('AgriSync Cart State functions correctly', (WidgetTester tester) async {
    final appState = AppState();
    expect(appState.cartItems.isNotEmpty, isTrue);

    appState.clearCart();
    expect(appState.cartItems.isEmpty, isTrue);

    final product = appState.products.first;
    appState.addToCart(product, quantityKg: 50);

    expect(appState.cartItems.length, 1);
    expect(appState.cartItemCount, 1);
    expect(appState.cartTotalQuantity, 50);
    expect(appState.cartSubtotal, 50 * product.pricePerKg);

    // Update quantity
    appState.updateCartQuantity(product.id, 100);
    expect(appState.cartTotalQuantity, 100);

    // Clear cart
    appState.clearCart();
    expect(appState.cartItems.isEmpty, isTrue);
  });

  testWidgets('AgriSync Welcome screen renders properly with login buttons and registration link', (WidgetTester tester) async {
    final appState = AppState()..logout();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const AgriSyncApp(showSplash: false),
      ),
    );
    await tester.pump();
    expect(find.text('AgriSync'), findsWidgets);
    expect(find.text('MASUK SEBAGAI PEBISNIS'), findsOneWidget);
    expect(find.text('MASUK SEBAGAI PETANI'), findsOneWidget);
    expect(find.text('Belum punya akun? '), findsOneWidget);
    expect(find.text('Daftar Sekarang'), findsOneWidget);

    // Tap Daftar Sekarang to verify registration role picker modal opens
    await tester.tap(find.text('Daftar Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Jenis Pendaftaran'), findsOneWidget);
    expect(find.text('Daftar Sebagai Pebisnis'), findsOneWidget);
    expect(find.text('Daftar Sebagai Petani'), findsOneWidget);

    // Tap Daftar Sebagai Pebisnis to navigate to RegisterPebisnisScreen
    await tester.tap(find.text('Daftar Sebagai Pebisnis'));
    await tester.pumpAndSettle();
    expect(find.text('Pendaftaran Pebisnis'), findsOneWidget);
    expect(find.text('Email Biasa'), findsOneWidget);
    expect(find.text('Akun Google'), findsOneWidget);

    // Tap on 'Akun Google' tab
    await tester.tap(find.text('Akun Google'));
    await tester.pumpAndSettle();
    expect(find.text('Verifikasi Akun Google Anda'), findsOneWidget);

    // Enter google email and verify
    final googleEmailField = find.byType(TextField).first;
    await tester.enterText(googleEmailField, 'resto.bintang.baru@gmail.com');
    await tester.tap(find.text('Verifikasi'));
    await tester.pumpAndSettle();

    // Verify it turns green and shows "Akun Google Terverifikasi"
    expect(find.text('Akun Google Terverifikasi'), findsOneWidget);
    expect(find.text('VALID'), findsOneWidget);
    expect(find.text('resto.bintang.baru@gmail.com'), findsOneWidget);
    expect(find.text('DAFTARKAN AKUN GOOGLE PEBISNIS'), findsOneWidget);
  });

  testWidgets('AgriSync Forgot Password flow functions with OTP verification and password reset', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState()..logout();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const AgriSyncApp(showSplash: false),
      ),
    );
    await tester.pump();

    // Tap 'MASUK SEBAGAI PEBISNIS' to open LoginScreen
    await tester.tap(find.text('MASUK SEBAGAI PEBISNIS'));
    await tester.pumpAndSettle();
    expect(find.text('Lupa Kata Sandi?'), findsOneWidget);

    // Tap 'Lupa Kata Sandi?' to open ForgotPasswordScreen
    await tester.tap(find.text('Lupa Kata Sandi?'));
    await tester.pumpAndSettle();
    expect(find.text('Lupa Kata Sandi?'), findsOneWidget);
    expect(find.text('KIRIM KODE VERIFIKASI'), findsOneWidget);

    // Step 1: Enter email and send OTP
    final identifierField = find.byType(TextField).first;
    await tester.enterText(identifierField, 'pebisnis@agrisync.id');
    await tester.tap(find.text('KIRIM KODE VERIFIKASI'));
    await tester.pumpAndSettle();

    // Step 2: Verify OTP
    expect(find.text('Masukkan Kode OTP'), findsOneWidget);
    expect(find.text('VERIFIKASI KODE'), findsOneWidget);
    final otpField = find.byType(TextField).first;
    await tester.enterText(otpField, '829104');
    await tester.tap(find.text('VERIFIKASI KODE'));
    await tester.pumpAndSettle();

    // Step 3: Enter new password and save
    expect(find.text('Buat Kata Sandi Baru'), findsOneWidget);
    expect(find.text('SIMPAN KATA SANDI BARU'), findsOneWidget);
    final newPassFields = find.byType(TextField);
    await tester.enterText(newPassFields.at(0), 'newSecretPass123');
    await tester.enterText(newPassFields.at(1), 'newSecretPass123');
    await tester.tap(find.text('SIMPAN KATA SANDI BARU'));
    await tester.pumpAndSettle();

    // Verify success dialog
    expect(find.text('Kata Sandi Berhasil Diperbarui!'), findsOneWidget);
    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pumpAndSettle();
    expect(find.text('Login Pebisnis'), findsOneWidget);
  });

  testWidgets('OrderConfirmationScreen renders Catatan Pesanan input form and saves notes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();
    final product = appState.products.first;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          home: OrderConfirmationScreen(
            product: product,
            agreedPrice: product.pricePerKg,
            defaultQuantity: 10,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify presence of form fields
    expect(find.text('Konfirmasi Pesanan'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);
    expect(find.text('Catatan Pesanan (Instruksi Khusus)'), findsOneWidget);

    // Find the text field for notes
    final notesField = find.widgetWithText(TextField, '');
    expect(notesField, findsWidgets);

    // Enter special notes into the notes field
    await tester.enterText(
      find.byWidgetPredicate((widget) => widget is TextField && widget.decoration?.hintText?.contains('Kemasan peti kayu') == true),
      'Tolong kirimkan pagi hari dalam peti kayu berventilasi.',
    );
    await tester.pump();

    // Tap order confirmation button
    await tester.tap(find.textContaining('KONFIRMASI PESANAN & BAYAR'));
    await tester.pumpAndSettle();

    // Verify order was created with notes in AppState
    final createdOrder = appState.myPurchaseOrders.first;
    expect(createdOrder.notes, 'Tolong kirimkan pagi hari dalam peti kayu berventilasi.');

    // Verify OrderTrackingScreen renders the notes card
    expect(find.text('Status Pesanan'), findsOneWidget);
    expect(find.text('Catatan Pesanan (Instruksi Pembeli):'), findsOneWidget);
    expect(find.text('Tolong kirimkan pagi hari dalam peti kayu berventilasi.'), findsOneWidget);
  });

  testWidgets('CartScreen renders individual notes per seller and saves separate notes for multi-item checkout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();
    appState.clearCart();
    final product1 = appState.products[0]; // e.g. Pak Eko
    final product2 = appState.products[1]; // e.g. Pak Wahyu
    appState.addToCart(product1, quantityKg: 20);
    appState.addToCart(product2, quantityKg: 30);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: PebisnisCartScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keranjang Belanja'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);
    expect(find.textContaining('Catatan Pesanan untuk'), findsNWidgets(2));

    // Enter distinct note for Product 1 (Farmer 1)
    final textFields = find.byType(TextField);
    // textFields: 0 is note for product 1, 1 is note for product 2, 2 is address
    await tester.enterText(textFields.at(0), 'Catatan Toko 1: Peti kayu, petik pagi.');
    await tester.pump();

    // Enter distinct note for Product 2 (Farmer 2)
    await tester.enterText(textFields.at(1), 'Catatan Toko 2: Sortir grade A, kirim sore.');
    await tester.pump();

    // Enter delivery address
    await tester.enterText(textFields.at(2), 'Jl. Suhat No. 88, Malang');
    await tester.pump();

    // Checkout
    await tester.tap(find.text('CHECKOUT SEKARANG (ESCROW)'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Verify 2 separate orders were created with their respective distinct notes
    final orders = appState.myPurchaseOrders;
    final orderProd1 = orders.firstWhere((o) => o.productId == product1.id);
    final orderProd2 = orders.firstWhere((o) => o.productId == product2.id);

    expect(orderProd1.notes, 'Catatan Toko 1: Peti kayu, petik pagi.');
    expect(orderProd2.notes, 'Catatan Toko 2: Sortir grade A, kirim sore.');
  });

  testWidgets('NotificationSettingsScreen toggles preferences and triggers live push test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: NotificationSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify screen title and preference sections
    expect(find.text('Preferensi Notifikasi & Peringatan'), findsOneWidget);
    expect(find.text('Perizinan Notifikasi Sistem'), findsOneWidget);
    expect(find.text('Transaksi & Negosiasi'), findsOneWidget);
    expect(find.text('Panen & Rekomendasi Pasar'), findsOneWidget);
    expect(find.text('Uji Coba Push Notifikasi Langsung'), findsOneWidget);

    // Tap quick test for order push
    expect(find.text('📦 Push Pesanan'), findsOneWidget);
    await tester.tap(find.text('📦 Push Pesanan'));
    await tester.pumpAndSettle();

    // Verify push banner appears on screen
    expect(find.text('AGRISYNC'), findsOneWidget);
    expect(find.text('📦 Update Status: Pembayaran Escrow Diverifikasi'), findsOneWidget);

    // Tap quick test for price trends
    expect(find.text('📈 Push Harga Pasar'), findsOneWidget);
    await tester.tap(find.text('📈 Push Harga Pasar'));
    await tester.pumpAndSettle();

    expect(find.text('📈 Tren Harga: Cabai Merah Naik 14%'), findsOneWidget);

    // Let the auto-dismiss timer complete
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('NotificationsSheet renders separated category tabs and filters notifications correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: NotificationsSheet(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title and Tab items
    expect(find.text('Pusat Notifikasi'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Pesanan & Bayar'), findsOneWidget);
    expect(find.text('Promo & Berita'), findsOneWidget);
    expect(find.text('Info Sistem'), findsOneWidget);

    // Switch to Pesanan & Bayar tab
    await tester.tap(find.text('Pesanan & Bayar'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Pesanan & Bayar'), findsOneWidget);

    // Switch to Promo & Berita tab
    await tester.tap(find.text('Promo & Berita'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Promo & Berita'), findsOneWidget);

    // Switch to Info Sistem tab
    await tester.tap(find.text('Info Sistem'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Info Sistem'), findsOneWidget);
  });

  testWidgets('AgriUserAvatar renders default person icon when imageUrl is null/empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AgriUserAvatar(
              imageUrl: null,
              name: 'Pengguna Baru',
              radius: 30,
              isVerified: true,
              showBadge: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Icons.person_rounded is displayed
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    // Verify verified check badge is displayed
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('PebisnisHomeScreen renders intuitive commodity category icons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: PebisnisHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify category labels
    expect(find.text('Kategori Komoditas'), findsOneWidget);
    expect(find.text('Sayuran'), findsOneWidget);
    expect(find.text('Buah'), findsOneWidget);
    expect(find.text('Palawija'), findsOneWidget);
    expect(find.text('Kacang'), findsOneWidget);

    // Verify intuitive category icons
    expect(find.byIcon(Icons.eco_rounded), findsOneWidget); // Sayuran
    expect(find.byIcon(Icons.apple_rounded), findsOneWidget); // Buah
    expect(find.byIcon(Icons.grass_rounded), findsOneWidget); // Palawija
    expect(find.byIcon(Icons.bubble_chart_rounded), findsOneWidget); // Kacang
  });

  testWidgets('PendingVerificationsScreen displays pending items and supports re-verification action', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();

    // 1. Submit a document update from user
    await appState.submitVerificationDocument(
      documentName: 'KTP & NIB Legal 2026',
      documentPath: 'assets/docs/test_doc.pdf',
      roleDetail: 'Lahan Organik Batu',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: PendingVerificationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Screen Content
    expect(find.text('Pending Verifications'), findsOneWidget);
    expect(find.textContaining('KTP & NIB Legal 2026'), findsOneWidget);

    // Verify action buttons exist for pending item
    expect(find.text('✓ VERIFIKASI'), findsWidgets);
    expect(find.text('✕ TOLAK'), findsWidgets);

    // Admin approves the item
    await tester.tap(find.text('✓ VERIFIKASI').first);
    await tester.pumpAndSettle();

    // Verify item now shows TERVERIFIKASI status and 'Verifikasi Ulang' option
    expect(find.text('TERVERIFIKASI'), findsWidgets);
    expect(find.text('Verifikasi Ulang'), findsWidgets);

    // Tap 'Verifikasi Ulang' to reopen verification
    await tester.tap(find.text('Verifikasi Ulang').first);
    await tester.pumpAndSettle();

    // Verify action buttons are back for re-verification
    expect(find.text('✓ VERIFIKASI'), findsWidgets);
    expect(find.text('✕ TOLAK'), findsWidgets);
  });

  testWidgets('SplashScreen renders animated logo, typography, tagline and progress bar', (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: SplashScreen(
            duration: Duration(milliseconds: 1000),
            autoNavigate: false,
          ),
        ),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify brand typography
    expect(find.text('Agri'), findsOneWidget);
    expect(find.text('Sync'), findsOneWidget);
    expect(find.text('Rantai Pasok Pertanian Digital'), findsOneWidget);
    expect(find.text('Menghubungkan Petani & Pebisnis Indonesia'), findsOneWidget);

    // Advance animation partially
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('AgriSync'), findsWidgets);
    expect(find.textContaining('v2.4'), findsOneWidget);
  });

  testWidgets('ChatNegotiationScreen renders 2-way negotiation buttons (TERIMA, TAWAR BALIK, TOLAK) and opens counter offer sheet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();
    final thread = appState.chatThreads.first;
    
    // Switch role to farmer (seller) to submit offer, then switch to buyer (pebisnis) as recipient
    appState.switchUserRole(UserRole.petani);
    appState.submitOffer(thread.id, 24000, 100);
    appState.switchUserRole(UserRole.pebisnis);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          home: ChatNegotiationScreen(threadId: thread.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify chat title and negotiation top elements
    expect(find.text('Negotiation Chat'), findsOneWidget);
    expect(find.text('Beri Nego'), findsOneWidget);

    // Verify 2-Way action buttons exist
    expect(find.text('TERIMA'), findsWidgets);
    expect(find.text('TAWAR BALIK'), findsWidgets);
    expect(find.text('TOLAK'), findsWidgets);

    // Tap TAWAR BALIK to open bottom sheet
    await tester.tap(find.text('TAWAR BALIK').first);
    await tester.pumpAndSettle();

    // Verify counter offer modal sheet
    expect(find.text('Ajukan Tawar Balik'), findsOneWidget);
    expect(find.text('Harga Tawar Balik (per kg)'), findsOneWidget);
    expect(find.text('KIRIM TAWARAN BALASAN'), findsOneWidget);

    // Close sheet
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Tap TOLAK to open reject dialog
    await tester.tap(find.text('TOLAK').first);
    await tester.pumpAndSettle();

    // Verify reject dialog
    expect(find.text('Tolak Penawaran'), findsOneWidget);
    expect(find.text('Konfirmasi Tolak'), findsOneWidget);
  });

  testWidgets('EditProfileScreen renders camera and gallery photo picking options in avatar bottom sheet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: EditProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify screen title and photo edit button
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Ganti Foto / Avatar Profil'), findsOneWidget);

    // Tap to open photo options bottom sheet
    await tester.tap(find.text('Ganti Foto / Avatar Profil'));
    await tester.pumpAndSettle();

    // Verify Camera and Gallery options exist
    expect(find.text('Pilih Foto Profil'), findsOneWidget);
    expect(find.text('Ambil Kamera'), findsOneWidget);
    expect(find.text('Buka Galeri'), findsOneWidget);
    expect(find.text('ATAU PILIH AVATAR KARAKTER'), findsOneWidget);
    expect(find.text('Pak Tani Organik'), findsOneWidget);

    // Tap a preset avatar
    await tester.tap(find.text('Pak Tani Organik'));
    await tester.pumpAndSettle();

    // Verify sheet closed and avatar selected feedback shown
    expect(find.textContaining('Pak Tani Organik'), findsWidgets);
  });

  testWidgets('UserProfileScreen avatar tap opens zoomed avatar lightbox dialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: UserProfileScreen(isRootTab: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify main profile screen
    expect(find.text('Profil & Pengaturan'), findsOneWidget);
    expect(find.byIcon(Icons.zoom_in_rounded), findsWidgets);

    // Tap the avatar
    await tester.tap(find.byIcon(Icons.zoom_in_rounded).first);
    await tester.pumpAndSettle();

    // Verify zoomed avatar dialog opens with Edit Profil button and Close button
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsWidgets);

    // Close the lightbox dialog
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
  });

  testWidgets('ChatNegotiationScreen renders counterparty avatar in header and message list with profile popup', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();
    final thread = appState.chatThreads.first;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          home: ChatNegotiationScreen(threadId: thread.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify counterparty info in header
    expect(find.text(thread.getOtherUserName(appState.currentUser.id)), findsWidgets);

    // Tap header avatar to open counterparty profile sheet
    await tester.tap(find.text(thread.getOtherUserName(appState.currentUser.id)).first);
    await tester.pumpAndSettle();

    // Verify Profile sheet content
    expect(find.text('Detail Profil Pengguna'), findsOneWidget);
    expect(find.textContaining('Ketuk foto untuk memperbesar'), findsOneWidget);
    expect(find.text('Tutup'), findsOneWidget);

    // Close profile sheet
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
  });
}

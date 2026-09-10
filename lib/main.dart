import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrisync/data/services/local_storage_service.dart';
import 'package:agrisync/data/services/auth_service.dart';
import 'package:agrisync/data/services/product_service.dart';
import 'package:agrisync/data/services/chat_service.dart';
import 'package:agrisync/data/services/order_service.dart';
import 'package:agrisync/data/services/admin_service.dart';
import 'package:agrisync/data/repositories/auth_repository.dart';
import 'package:agrisync/data/repositories/product_repository.dart';
import 'package:agrisync/data/repositories/chat_repository.dart';
import 'package:agrisync/data/repositories/order_repository.dart';
import 'package:agrisync/data/repositories/admin_repository.dart';
import 'package:agrisync/data/services/notification_service.dart';
import 'package:agrisync/data/repositories/notification_repository.dart';
import 'package:agrisync/state/app_state.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/ui/theme/app_theme.dart';
import 'package:agrisync/data/services/firebase_service.dart';
import 'package:agrisync/data/services/push_notification_service.dart';
import 'package:agrisync/ui/screens/auth/welcome_screen.dart';
import 'package:agrisync/ui/screens/pebisnis/pebisnis_home_screen.dart';

import 'package:agrisync/ui/screens/petani/petani_home_screen.dart';
import 'package:agrisync/ui/screens/splash/splash_screen.dart';
import 'package:agrisync/ui/screens/admin/admin_dashboard_screen.dart';

import 'package:agrisync/data/services/system_notification_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize System Notifications (Android Channels & Permissions)
  await SystemNotificationHelper.ensureInitialized();

  // Initialize Firebase Multiplatform (Cloud Services CPMK 5)
  await FirebaseService.initialize();

  // Initialize Persistent Local Storage
  final storage = await LocalStorageService.init();


  // Instantiate Services with Storage
  final authService = MockAuthService(storage: storage);
  final productService = MockProductService(storage: storage);
  final chatService = MockChatService(storage: storage);
  final orderService = MockOrderService(storage: storage);
  final adminService = MockAdminService(storage: storage);
  final notificationService = MockNotificationService(storage: storage);

  // Instantiate Repositories (Data Layer)
  final authRepository = AuthRepositoryImpl(authService: authService);
  final productRepository = ProductRepositoryImpl(productService: productService);
  final chatRepository = ChatRepositoryImpl(chatService: chatService);
  final orderRepository = OrderRepositoryImpl(orderService: orderService);
  final adminRepository = AdminRepositoryImpl(adminService: adminService);
  final notificationRepository = NotificationRepositoryImpl(notificationService: notificationService);

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalStorageService>.value(value: storage),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<ProductRepository>.value(value: productRepository),
        Provider<ChatRepository>.value(value: chatRepository),
        Provider<OrderRepository>.value(value: orderRepository),
        Provider<AdminRepository>.value(value: adminRepository),
        Provider<NotificationRepository>.value(value: notificationRepository),
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(
            authRepository: authRepository,
            productRepository: productRepository,
            chatRepository: chatRepository,
            orderRepository: orderRepository,
            adminRepository: adminRepository,
            notificationRepository: notificationRepository,
            storage: storage,
          ),
        ),
      ],
      child: const AgriSyncApp(),
    ),
  );
}

class AgriSyncApp extends StatelessWidget {
  final bool showSplash;

  const AgriSyncApp({
    super.key,
    this.showSplash = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MaterialApp(
          navigatorKey: PushNotificationService.navigatorKey,
          title: 'AgriSync',
          debugShowCheckedModeBanner: false,
          theme: AgriTheme.lightTheme,
          darkTheme: AgriTheme.darkTheme,
          themeMode: appState.themeMode,
          home: showSplash
              ? const SplashScreen()
              : Builder(
                  builder: (context) {
                    if (!appState.isLoggedIn) {
                      return const WelcomeScreen();
                    }

                    switch (appState.currentUser.role) {
                      case UserRole.pebisnis:
                        return const PebisnisHomeScreen();
                      case UserRole.petani:
                        return const PetaniHomeScreen();
                      case UserRole.admin:
                        return const AdminDashboardScreen();
                    }
                  },
                ),
        );
      },
    );
  }
}


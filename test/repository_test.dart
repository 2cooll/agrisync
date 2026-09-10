import 'package:flutter_test/flutter_test.dart';
import 'package:agrisync/data/repositories/auth_repository.dart';
import 'package:agrisync/data/repositories/product_repository.dart';
import 'package:agrisync/data/repositories/chat_repository.dart';
import 'package:agrisync/data/repositories/order_repository.dart';
import 'package:agrisync/data/repositories/admin_repository.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/data/models/product_model.dart';

void main() {
  group('Repository Layer Unit Tests', () {
    test('AuthRepository handles login and role switching', () {
      final authRepo = AuthRepositoryImpl();
      expect(authRepo.currentUser.role, equals(UserRole.pebisnis));

      authRepo.switchRole(UserRole.petani);
      expect(authRepo.currentUser.role, equals(UserRole.petani));

      authRepo.logout();
      expect(authRepo.isLoggedIn, isFalse);
    });

    test('ProductRepository performs search and CRUD operations', () {
      final productRepo = ProductRepositoryImpl();
      final initialCount = productRepo.getProducts().length;

      final testProduct = ProductModel(
        id: 'repo_test_1',
        title: 'Kopi Robusta Malang',
        category: 'Palawija',
        farmerId: 'usr_petani_1',
        farmerName: 'Pak Eko',
        farmerLocation: 'Dampit, Malang',
        pricePerKg: 45000,
        stockKg: 200,
        qualityGrade: 'Grade A',
        harvestEstimate: 'Ready',
        description: 'Biji kopi pilihan',
        imageUrl: 'https://example.com/kopi.jpg',
        createdAt: DateTime.now(),
      );

      productRepo.addProduct(testProduct);
      expect(productRepo.getProducts().length, equals(initialCount + 1));
      expect(productRepo.getProductById('repo_test_1'), isNotNull);

      final filtered = productRepo.getFilteredProducts(searchQuery: 'Robusta');
      expect(filtered.length, equals(1));

      productRepo.deleteProduct('repo_test_1');
      expect(productRepo.getProducts().length, equals(initialCount));
    });

    test('Chat, Order, Admin Repositories initialize properly', () {
      final chatRepo = ChatRepositoryImpl();
      final orderRepo = OrderRepositoryImpl();
      final adminRepo = AdminRepositoryImpl();

      expect(chatRepo.getChatThreads().isNotEmpty, isTrue);
      expect(orderRepo.getOrders().isNotEmpty, isTrue);
      expect(adminRepo.getVerifications().isNotEmpty, isTrue);
      expect(adminRepo.getPendingVerifikasiStat(), greaterThan(0));
    });
  });
}

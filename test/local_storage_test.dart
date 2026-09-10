import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrisync/data/services/local_storage_service.dart';
import 'package:agrisync/data/models/user_model.dart';
import 'package:agrisync/data/models/product_model.dart';

void main() {
  group('LocalStorageService Unit Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.init();
    });

    test('Saves and loads registered user account and login state', () async {
      final newUser = UserModel(
        id: 'usr_test_999',
        name: 'Petani Organik Batu',
        phone: '081233445566',
        role: UserRole.petani,
        farmLocation: 'Batu, Jawa Timur',
        joinedDate: DateTime(2026, 8, 1),
      );

      await storage.saveCurrentUser(newUser);
      await storage.saveIsLoggedIn(true);

      final loadedUser = storage.loadCurrentUser();
      expect(loadedUser.id, equals('usr_test_999'));
      expect(loadedUser.name, equals('Petani Organik Batu'));
      expect(loadedUser.role, equals(UserRole.petani));
      expect(storage.loadIsLoggedIn(), isTrue);
    });

    test('Saves and loads products persistently', () async {
      final products = [
        ProductModel(
          id: 'p_save_1',
          title: 'Wortel Brastagi',
          category: 'Sayuran',
          farmerId: 'usr_1',
          farmerName: 'Pak Tani',
          farmerLocation: 'Brastagi',
          pricePerKg: 12000,
          stockKg: 300,
          qualityGrade: 'Grade A',
          harvestEstimate: 'Ready',
          description: 'Wortel manis segar',
          imageUrl: 'https://example.com/wortel.jpg',
          createdAt: DateTime.now(),
        ),
      ];

      await storage.saveProducts(products);
      final loaded = storage.loadProducts();
      expect(loaded.length, equals(1));
      expect(loaded.first.title, equals('Wortel Brastagi'));
    });

    test('Registry saves and finds user by email or phone, binds Google role', () async {
      final user = UserModel(
        id: 'usr_reg_1',
        name: 'Resto Sunda',
        phone: '081299887766',
        email: 'sunda@resto.com',
        role: UserRole.pebisnis,
        businessType: 'Restoran',
        joinedDate: DateTime.now(),
      );

      await storage.saveRegisteredUser(user, password: 'password123');
      final found = storage.findUserByEmailOrPhone('sunda@resto.com');
      expect(found, isNotNull);
      expect(found!.name, equals('Resto Sunda'));
      expect(found.role, equals(UserRole.pebisnis));

      await storage.saveGoogleRoleBinding('google.buyer@gmail.com', 'pebisnis');
      final boundRole = storage.getRoleForGoogleEmail('google.buyer@gmail.com');
      expect(boundRole, equals('pebisnis'));
    });
  });
}

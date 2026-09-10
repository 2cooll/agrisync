import '../models/user_model.dart';
import '../models/verification_model.dart';
import '../mock_data.dart';
import 'local_storage_service.dart';

abstract class IAuthService {
  UserModel get currentUser;
  bool get isLoggedIn;
  UserModel switchRole(UserRole role);
  UserModel login({required String phone, required String password, required UserRole role, String? email});
  UserModel loginWithGoogle({required UserRole role, String? email, String? displayName});
  ({UserModel user, VerificationItem verification}) registerPetani({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String farmLocation,
    String? documentPath,
  });
  ({UserModel user, VerificationItem verification}) registerPebisnis({
    required String businessName,
    required String businessType,
    required String phone,
    required String email,
    required String password,
    String? documentPath,
  });
  void updateProfile({
    String? name,
    String? businessType,
    String? farmLocation,
    String? avatarUrl,
    String? email,
    String? phone,
    bool? isProMember,
    DateTime? subscriptionExpiry,
  });
  bool verifyPassword(String password);
  void changePassword({required String oldPassword, required String newPassword});
  void resetPassword({required String identifier, required String newPassword});
  void logout();
  void setCurrentUser(UserModel user);
  void updateUserVerificationStatus(String userId, VerificationStatus status);
}

class MockAuthService implements IAuthService {
  final LocalStorageService? _storage;
  static final Map<String, String> _inMemoryGoogleBindings = {};
  static final Map<String, String> _inMemoryCredentials = {
    '081234567890': 'password123',
    '081987654321': 'password123',
    '08111222333': 'password123',
    'pebisnis@agrisync.id': 'password123',
    'petani@agrisync.id': 'password123',
    'admin@agrisync.id': 'password123',
  };
  static final List<UserModel> _inMemoryUsers = [
    MockData.defaultPebisnis.copyWith(email: 'pebisnis@agrisync.id'),
    MockData.defaultPetani.copyWith(email: 'petani@agrisync.id'),
    MockData.defaultAdmin.copyWith(email: 'admin@agrisync.id'),
  ];
  late UserModel _currentUser;
  late bool _isLoggedIn;

  MockAuthService({LocalStorageService? storage}) : _storage = storage {
    _currentUser = _storage?.loadCurrentUser() ?? MockData.defaultPebisnis;
    _isLoggedIn = _storage?.loadIsLoggedIn() ?? true;
  }

  UserModel? _findUser(String query) {
    final clean = query.trim().toLowerCase();
    if (_storage != null) {
      final u = _storage.findUserByEmailOrPhone(clean);
      if (u != null) return u;
    }
    for (final u in _inMemoryUsers) {
      if (u.email?.trim().toLowerCase() == clean || u.phone.trim().toLowerCase() == clean) {
        return u;
      }
    }
    return null;
  }

  @override
  UserModel get currentUser => _currentUser;

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  void setCurrentUser(UserModel user) {
    _currentUser = user;
    _isLoggedIn = true;
    final cleanEmail = user.email?.trim().toLowerCase();
    final cleanPhone = user.phone.trim().toLowerCase();
    final existingIdx = _inMemoryUsers.indexWhere((u) =>
        u.id == user.id ||
        (cleanEmail != null && u.email?.trim().toLowerCase() == cleanEmail) ||
        (cleanPhone.isNotEmpty && u.phone.trim().toLowerCase() == cleanPhone));
    if (existingIdx >= 0) {
      _inMemoryUsers[existingIdx] = user;
    } else {
      _inMemoryUsers.add(user);
    }
    _storage?.saveCurrentUser(_currentUser);
    _storage?.saveRegisteredUser(_currentUser);
    _storage?.saveIsLoggedIn(true);
  }

  @override
  void updateUserVerificationStatus(String userId, VerificationStatus status) {
    final idx = _inMemoryUsers.indexWhere((u) => u.id == userId);
    if (idx >= 0) {
      _inMemoryUsers[idx] = _inMemoryUsers[idx].copyWith(verificationStatus: status);
    }
    if (_currentUser.id == userId) {
      _currentUser = _currentUser.copyWith(verificationStatus: status);
      _storage?.saveCurrentUser(_currentUser);
    }
    _storage?.updateUserVerificationStatus(userId, status);
  }

  @override
  UserModel switchRole(UserRole role) {
    switch (role) {
      case UserRole.petani:
        _currentUser = MockData.defaultPetani;
        break;
      case UserRole.pebisnis:
        _currentUser = MockData.defaultPebisnis;
        break;
      case UserRole.admin:
        _currentUser = MockData.defaultAdmin;
        break;
    }
    _isLoggedIn = true;
    _storage?.saveCurrentUser(_currentUser);
    _storage?.saveIsLoggedIn(true);
    return _currentUser;
  }

  @override
  UserModel login({required String phone, required String password, required UserRole role, String? email}) {
    final query = (email != null && email.trim().isNotEmpty) ? email.trim() : phone.trim();
    if (query.isEmpty) {
      throw Exception('Harap masukkan email atau nomor telepon Anda.');
    }

    final found = _findUser(query);

    if (found == null) {
      throw Exception('Akun dengan email atau nomor telepon "$query" tidak terdaftar. Silakan periksa kembali atau registrasi terlebih dahulu.');
    }

    if (found.role != role) {
      throw Exception(
        'Akun ini terdaftar sebagai peran ${found.role.name.toUpperCase()}, bukan ${role.name.toUpperCase()}.\n'
        'Silakan pilih peran ${found.role.name.toUpperCase()} pada pilihan di atas.',
      );
    }

    final cleanQuery = query.trim().toLowerCase();
    final cleanPhone = found.phone.trim().toLowerCase();
    final cleanEmail = found.email?.trim().toLowerCase();

    final savedPassword = _storage?.getUserPassword(query) ??
        _storage?.getUserPassword(cleanPhone) ??
        (cleanEmail != null ? _storage?.getUserPassword(cleanEmail) : null) ??
        _inMemoryCredentials[cleanQuery] ??
        _inMemoryCredentials[cleanPhone] ??
        (cleanEmail != null ? _inMemoryCredentials[cleanEmail] : null);

    if (savedPassword != null) {
      final isTemplateDots = (password == '••••••••' && (savedPassword == 'password123' || savedPassword == '••••••••'));
      if (savedPassword != password && !isTemplateDots) {
        throw Exception('Kata sandi yang Anda masukkan salah. Silakan periksa kembali kata sandi Anda.');
      }
    } else {
      if (password != 'password123' && password != '••••••••' && password.length < 6) {
        throw Exception('Kata sandi yang Anda masukkan salah. Silakan periksa kembali kata sandi Anda.');
      }
    }

    _currentUser = found;
    _isLoggedIn = true;
    _storage?.saveCurrentUser(_currentUser);
    _storage?.saveIsLoggedIn(true);
    return _currentUser;
  }

  @override
  UserModel loginWithGoogle({required UserRole role, String? email, String? displayName}) {
    final effectiveEmail = email?.trim().toLowerCase() ?? 'user.${role.name}@gmail.com';
    final effectiveName = displayName ?? (role == UserRole.petani ? 'Budi Santoso (Google)' : (role == UserRole.pebisnis ? 'Resto Berkah Google' : 'Admin AgriSync (Google)'));

    // ATURAN 1 AKUN GOOGLE = 1 ROLE
    final existingRoleName = _storage?.getRoleForGoogleEmail(effectiveEmail) ?? _inMemoryGoogleBindings[effectiveEmail];
    if (existingRoleName != null && existingRoleName != role.name) {
      throw Exception(
        'Akun Google ini ($effectiveEmail) sudah terdaftar sebagai ${existingRoleName.toUpperCase()}.\n\n'
        'Satu akun Google hanya dapat digunakan untuk 1 peran. Silakan masuk sesuai peran Anda yang sudah terdaftar.',
      );
    }

    final existingUser = _findUser(effectiveEmail);
    if (existingUser != null && existingUser.role == role) {
      _currentUser = existingUser;
      _isLoggedIn = true;
      _storage?.saveCurrentUser(_currentUser);
      _storage?.saveIsLoggedIn(true);
      return _currentUser;
    }

    final googleUser = UserModel(
      id: 'usr_google_${DateTime.now().millisecondsSinceEpoch}',
      name: effectiveName,
      phone: effectiveEmail,
      email: effectiveEmail,
      role: role,
      farmLocation: role == UserRole.petani ? 'Batu, Jawa Timur' : null,
      businessType: role == UserRole.pebisnis ? 'Kuliner & Restoran' : null,
      documentPath: 'Google_Verified_ID',
      verificationStatus: VerificationStatus.verified,
      joinedDate: DateTime.now(),
      avatarUrl: 'https://placehold.co/100x100/34A853/ffffff?text=G',
    );

    _currentUser = googleUser;
    _isLoggedIn = true;
    _storage?.saveCurrentUser(_currentUser);
    _storage?.saveRegisteredUser(_currentUser);
    _storage?.saveGoogleRoleBinding(effectiveEmail, role.name);
    _inMemoryGoogleBindings[effectiveEmail] = role.name;
    _storage?.saveIsLoggedIn(true);
    return _currentUser;
  }

  @override
  ({UserModel user, VerificationItem verification}) registerPetani({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String farmLocation,
    String? documentPath,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phone.trim();

    // Validasi 1: Cek apakah email sudah terdaftar (1 Email = 1 Peran & Akun Unik)
    final existingUserByEmail = _findUser(cleanEmail);
    if (existingUserByEmail != null) {
      final existingRole = existingUserByEmail.role.name.toUpperCase();
      throw Exception(
        'Email "$email" sudah terdaftar sebagai akun $existingRole.\n\n'
        'Satu email hanya dapat digunakan untuk 1 akun dan 1 peran. Silakan masuk menggunakan email tersebut atau gunakan email lain.',
      );
    }

    // Validasi 2: Cek nomor telepon
    final existingUserByPhone = _findUser(cleanPhone);
    if (existingUserByPhone != null) {
      final existingRole = existingUserByPhone.role.name.toUpperCase();
      throw Exception(
        'Nomor telepon "$phone" sudah terdaftar sebagai akun $existingRole.\n\n'
        'Satu nomor telepon hanya dapat digunakan untuk 1 akun. Silakan masuk atau gunakan nomor lain.',
      );
    }

    // Validasi 3: Cek Google role binding jika ada
    final existingGoogleRole = _storage?.getRoleForGoogleEmail(cleanEmail) ?? _inMemoryGoogleBindings[cleanEmail];
    if (existingGoogleRole != null) {
      throw Exception(
        'Email "$email" sudah terhubung dengan akun Google peran ${existingGoogleRole.toUpperCase()}.\n\n'
        'Satu email hanya dapat digunakan untuk 1 peran. Silakan masuk menggunakan Google.',
      );
    }

    final newUser = UserModel(
      id: 'usr_petani_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email,
      role: UserRole.petani,
      farmLocation: farmLocation,
      documentPath: documentPath ?? 'KTP_Sertifikat.pdf',
      verificationStatus: VerificationStatus.pending,
      joinedDate: DateTime.now(),
    );

    _currentUser = newUser;
    _isLoggedIn = true;
    _inMemoryCredentials[cleanEmail] = password;
    _inMemoryCredentials[cleanPhone] = password;
    _inMemoryUsers.add(newUser);
    _storage?.saveCurrentUser(_currentUser);
    _storage?.saveRegisteredUser(_currentUser, password: password);
    _storage?.saveIsLoggedIn(true);

    final verification = VerificationItem(
      id: 'ver_${DateTime.now().millisecondsSinceEpoch}',
      userId: newUser.id,
      userName: newUser.name,
      userRole: UserRole.petani,
      roleDetail: 'Petani (${newUser.farmLocation})',
      location: farmLocation,
      registrationType: 'Pendaftaran 2026',
      documentName: newUser.documentPath ?? 'KTP_Sertifikat.pdf',
      documentUrl: 'https://placehold.co/400x200/8CBF37/ffffff?text=KTP+${newUser.name}',
      submissionDate: DateTime.now(),
      status: VerificationStatus.pending,
    );

    return (user: newUser, verification: verification);
  }

  @override
  ({UserModel user, VerificationItem verification}) registerPebisnis({
    required String businessName,
    required String businessType,
    required String phone,
    required String email,
    required String password,
    String? documentPath,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phone.trim();

    // Validasi 1: Cek apakah email sudah terdaftar (1 Email = 1 Peran & Akun Unik)
    final existingUserByEmail = _findUser(cleanEmail);
    if (existingUserByEmail != null) {
      final existingRole = existingUserByEmail.role.name.toUpperCase();
      throw Exception(
        'Email "$email" sudah terdaftar sebagai akun $existingRole.\n\n'
        'Satu email hanya dapat digunakan untuk 1 akun dan 1 peran. Silakan masuk menggunakan email tersebut atau gunakan email lain.',
      );
    }

    // Validasi 2: Cek nomor telepon
    final existingUserByPhone = _findUser(cleanPhone);
    if (existingUserByPhone != null) {
      final existingRole = existingUserByPhone.role.name.toUpperCase();
      throw Exception(
        'Nomor telepon "$phone" sudah terdaftar sebagai akun $existingRole.\n\n'
        'Satu nomor telepon hanya dapat digunakan untuk 1 akun. Silakan masuk atau gunakan nomor lain.',
      );
    }

    // Validasi 3: Cek Google role binding jika ada
    final existingGoogleRole = _storage?.getRoleForGoogleEmail(cleanEmail) ?? _inMemoryGoogleBindings[cleanEmail];
    if (existingGoogleRole != null) {
      throw Exception(
        'Email "$email" sudah terhubung dengan akun Google peran ${existingGoogleRole.toUpperCase()}.\n\n'
        'Satu email hanya dapat digunakan untuk 1 peran. Silakan masuk menggunakan Google.',
      );
    }

    final newUser = UserModel(
      id: 'usr_pebisnis_${DateTime.now().millisecondsSinceEpoch}',
      name: businessName,
      phone: phone,
      email: email,
      role: UserRole.pebisnis,
      businessType: businessType,
      documentPath: documentPath ?? 'Izin_Usaha.pdf',
      verificationStatus: VerificationStatus.pending,
      joinedDate: DateTime.now(),
    );

    _currentUser = newUser;
    _isLoggedIn = true;
    _inMemoryCredentials[cleanEmail] = password;
    _inMemoryCredentials[cleanPhone] = password;
    _inMemoryUsers.add(newUser);
    _storage?.saveCurrentUser(_currentUser);
    _storage?.saveRegisteredUser(_currentUser, password: password);
    _storage?.saveIsLoggedIn(true);

    final verification = VerificationItem(
      id: 'ver_${DateTime.now().millisecondsSinceEpoch}',
      userId: newUser.id,
      userName: newUser.name,
      userRole: UserRole.pebisnis,
      roleDetail: 'Pebisnis ($businessType)',
      location: 'Indonesia',
      registrationType: 'Pendaftaran 2026',
      documentName: newUser.documentPath ?? 'Izin_Usaha.pdf',
      documentUrl: 'https://placehold.co/400x200/263211/ffffff?text=NIB+${newUser.name}',
      submissionDate: DateTime.now(),
      status: VerificationStatus.pending,
    );

    return (user: newUser, verification: verification);
  }

  @override
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
    _currentUser = _currentUser.copyWith(
      name: name ?? _currentUser.name,
      businessType: businessType ?? _currentUser.businessType,
      farmLocation: farmLocation ?? _currentUser.farmLocation,
      avatarUrl: avatarUrl ?? _currentUser.avatarUrl,
      email: email ?? _currentUser.email,
      phone: phone ?? _currentUser.phone,
      isProMember: isProMember ?? _currentUser.isProMember,
      subscriptionExpiry: subscriptionExpiry ?? _currentUser.subscriptionExpiry,
    );
    final idx = _inMemoryUsers.indexWhere((u) => u.id == _currentUser.id);
    if (idx >= 0) {
      _inMemoryUsers[idx] = _currentUser;
    }
    _storage?.saveCurrentUser(_currentUser);
    _storage?.saveRegisteredUser(_currentUser);
  }

  @override
  bool verifyPassword(String password) {
    final email = _currentUser.email?.trim().toLowerCase();
    final phone = _currentUser.phone.trim();

    final saved = (email != null ? _storage?.getUserPassword(email) : null) ??
        _storage?.getUserPassword(phone) ??
        (email != null ? _inMemoryCredentials[email] : null) ??
        _inMemoryCredentials[phone] ??
        'password123';

    return password == saved || saved == '••••••••';
  }

  @override
  void changePassword({required String oldPassword, required String newPassword}) {
    if (!verifyPassword(oldPassword)) {
      throw Exception('Kata sandi saat ini yang Anda masukkan salah. Silakan periksa kembali kata sandi lama Anda.');
    }

    if (newPassword.length < 6) {
      throw Exception('Kata sandi baru minimal 6 karakter.');
    }

    if (oldPassword == newPassword) {
      throw Exception('Kata sandi baru tidak boleh sama dengan kata sandi lama.');
    }

    final email = _currentUser.email?.trim().toLowerCase();
    final phone = _currentUser.phone.trim();

    if (email != null) {
      _inMemoryCredentials[email] = newPassword;
      _storage?.updateUserPassword(email, newPassword);
    }
    if (phone.isNotEmpty) {
      _inMemoryCredentials[phone] = newPassword;
      _storage?.updateUserPassword(phone, newPassword);
    }
  }

  @override
  void resetPassword({required String identifier, required String newPassword}) {
    if (newPassword.length < 6) {
      throw Exception('Kata sandi baru minimal 6 karakter.');
    }
    final clean = identifier.trim().toLowerCase();
    _inMemoryCredentials[clean] = newPassword;
    _storage?.updateUserPassword(clean, newPassword);

    final user = _findUser(identifier);
    if (user != null) {
      if (user.email != null) {
        _inMemoryCredentials[user.email!.trim().toLowerCase()] = newPassword;
        _storage?.updateUserPassword(user.email!, newPassword);
      }
      if (user.phone.isNotEmpty) {
        _inMemoryCredentials[user.phone.trim()] = newPassword;
        _storage?.updateUserPassword(user.phone, newPassword);
      }
      if (_currentUser.id == user.id) {
        _currentUser = _currentUser.copyWith();
      }
    }
  }

  @override
  void logout() {
    _isLoggedIn = false;
    _storage?.saveIsLoggedIn(false);
  }
}

import '../models/user_model.dart';
import '../models/verification_model.dart';
import '../services/auth_service.dart';

abstract class AuthRepository {
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

class AuthRepositoryImpl implements AuthRepository {
  final IAuthService _authService;

  AuthRepositoryImpl({IAuthService? authService})
      : _authService = authService ?? MockAuthService();

  @override
  UserModel get currentUser => _authService.currentUser;

  @override
  bool get isLoggedIn => _authService.isLoggedIn;

  @override
  void setCurrentUser(UserModel user) => _authService.setCurrentUser(user);

  @override
  void updateUserVerificationStatus(String userId, VerificationStatus status) =>
      _authService.updateUserVerificationStatus(userId, status);

  @override
  UserModel switchRole(UserRole role) => _authService.switchRole(role);

  @override
  UserModel login({required String phone, required String password, required UserRole role, String? email}) =>
      _authService.login(phone: phone, password: password, role: role, email: email);

  @override
  UserModel loginWithGoogle({required UserRole role, String? email, String? displayName}) =>
      _authService.loginWithGoogle(role: role, email: email, displayName: displayName);

  @override
  ({UserModel user, VerificationItem verification}) registerPetani({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String farmLocation,
    String? documentPath,
  }) =>
      _authService.registerPetani(
        name: name,
        phone: phone,
        email: email,
        password: password,
        farmLocation: farmLocation,
        documentPath: documentPath,
      );

  @override
  ({UserModel user, VerificationItem verification}) registerPebisnis({
    required String businessName,
    required String businessType,
    required String phone,
    required String email,
    required String password,
    String? documentPath,
  }) =>
      _authService.registerPebisnis(
        businessName: businessName,
        businessType: businessType,
        phone: phone,
        email: email,
        password: password,
        documentPath: documentPath,
      );

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
  }) =>
      _authService.updateProfile(
        name: name,
        businessType: businessType,
        farmLocation: farmLocation,
        avatarUrl: avatarUrl,
        email: email,
        phone: phone,
        isProMember: isProMember,
        subscriptionExpiry: subscriptionExpiry,
      );

  @override
  bool verifyPassword(String password) => _authService.verifyPassword(password);

  @override
  void changePassword({required String oldPassword, required String newPassword}) =>
      _authService.changePassword(oldPassword: oldPassword, newPassword: newPassword);

  @override
  void resetPassword({required String identifier, required String newPassword}) =>
      _authService.resetPassword(identifier: identifier, newPassword: newPassword);

  @override
  void logout() => _authService.logout();
}

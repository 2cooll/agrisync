import '../models/user_model.dart';
import '../models/verification_model.dart';
import '../models/order_model.dart';
import '../services/admin_service.dart';

abstract class AdminRepository {
  List<VerificationItem> getVerifications();
  List<VerificationItem> getPendingVerifications();
  List<DisputeItem> getDisputes();
  void addVerification(VerificationItem item);
  void approveVerification(String id);
  void rejectVerification(String id, String reason);
  void reopenVerification(String id);
  void resolveDispute(String id, String notes);
  int getTotalPetaniStat(int baseCount);
  int getTotalPebisnisStat(int baseCount);
  int getPendingVerifikasiStat();
  int getActiveTransactionStat(List<OrderModel> orders, int baseCount);
  int getActiveDisputesStat();
}

class AdminRepositoryImpl implements AdminRepository {
  final IAdminService _adminService;

  AdminRepositoryImpl({IAdminService? adminService})
      : _adminService = adminService ?? MockAdminService();

  @override
  List<VerificationItem> getVerifications() => _adminService.getVerifications();

  @override
  List<VerificationItem> getPendingVerifications() => _adminService
      .getVerifications()
      .where((v) => v.status == VerificationStatus.pending)
      .toList();

  @override
  List<DisputeItem> getDisputes() => _adminService.getDisputes();

  @override
  void addVerification(VerificationItem item) => _adminService.addVerification(item);

  @override
  void approveVerification(String id) => _adminService.approveVerification(id);

  @override
  void rejectVerification(String id, String reason) =>
      _adminService.rejectVerification(id, reason);

  @override
  void reopenVerification(String id) =>
      _adminService.reopenVerification(id);

  @override
  void resolveDispute(String id, String notes) =>
      _adminService.resolveDispute(id, notes);

  @override
  int getTotalPetaniStat(int baseCount) =>
      baseCount +
      _adminService
          .getVerifications()
          .where((v) => v.userRole == UserRole.petani && v.status == VerificationStatus.verified)
          .length;

  @override
  int getTotalPebisnisStat(int baseCount) =>
      baseCount +
      _adminService
          .getVerifications()
          .where((v) => v.userRole == UserRole.pebisnis && v.status == VerificationStatus.verified)
          .length;

  @override
  int getPendingVerifikasiStat() => getPendingVerifications().length;

  @override
  int getActiveTransactionStat(List<OrderModel> orders, int baseCount) =>
      orders.where((o) => o.status != OrderStatus.selesai).length + baseCount;

  @override
  int getActiveDisputesStat() =>
      _adminService.getDisputes().where((d) => !d.isResolved).length;
}

import '../models/verification_model.dart';
import '../models/user_model.dart';
import '../mock_data.dart';
import 'local_storage_service.dart';

abstract class IAdminService {
  List<VerificationItem> getVerifications();
  List<DisputeItem> getDisputes();
  void addVerification(VerificationItem item);
  void approveVerification(String id);
  void rejectVerification(String id, String reason);
  void reopenVerification(String id);
  void resolveDispute(String id, String notes);
}

class MockAdminService implements IAdminService {
  final LocalStorageService? _storage;
  late List<VerificationItem> _verifications;
  late List<DisputeItem> _disputes;

  MockAdminService({
    LocalStorageService? storage,
    List<VerificationItem>? initialVerifications,
    List<DisputeItem>? initialDisputes,
  }) : _storage = storage {
    _verifications =
        initialVerifications ?? (_storage?.loadVerifications() ?? MockData.getInitialVerifications());
    _disputes = initialDisputes ?? (_storage?.loadDisputes() ?? MockData.getInitialDisputes());
  }

  @override
  List<VerificationItem> getVerifications() => List.unmodifiable(_verifications);

  @override
  List<DisputeItem> getDisputes() => List.unmodifiable(_disputes);

  @override
  void addVerification(VerificationItem item) {
    // Remove previous verification record for this user so updated document is at the top of pending queue
    _verifications.removeWhere((v) => v.userId == item.userId || (item.userName.isNotEmpty && v.userName == item.userName));
    _verifications.insert(0, item);
    _storage?.saveVerifications(_verifications);
  }

  @override
  void approveVerification(String id) {
    final index = _verifications.indexWhere((v) => v.id == id);
    if (index != -1) {
      _verifications[index] = _verifications[index].copyWith(
        status: VerificationStatus.verified,
        rejectionReason: '',
      );
      _storage?.saveVerifications(_verifications);
    }
  }

  @override
  void rejectVerification(String id, String reason) {
    final index = _verifications.indexWhere((v) => v.id == id);
    if (index != -1) {
      _verifications[index] = _verifications[index].copyWith(
        status: VerificationStatus.rejected,
        rejectionReason: reason,
      );
      _storage?.saveVerifications(_verifications);
    }
  }

  @override
  void reopenVerification(String id) {
    final index = _verifications.indexWhere((v) => v.id == id);
    if (index != -1) {
      _verifications[index] = _verifications[index].copyWith(
        status: VerificationStatus.pending,
        rejectionReason: '',
      );
      _storage?.saveVerifications(_verifications);
    }
  }

  @override
  void resolveDispute(String id, String notes) {
    final index = _disputes.indexWhere((d) => d.id == id);
    if (index != -1) {
      _disputes[index] = _disputes[index].copyWith(
        isResolved: true,
        resolutionNotes: notes,
      );
      _storage?.saveDisputes(_disputes);
    }
  }
}

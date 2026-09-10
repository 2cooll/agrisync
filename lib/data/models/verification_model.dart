import 'user_model.dart';

class VerificationItem {
  final String id;
  final String userId;
  final String userName;
  final UserRole userRole;
  final String roleDetail; // Petani or Pebisnis (Restoran)
  final String location;
  final String registrationType; // e.g. Pendaftaran 2026, KTP & Sertifikat Lahan, NIB Bisnis
  final String documentName;
  final String documentUrl;
  final DateTime submissionDate;
  final VerificationStatus status;
  final String? rejectionReason;

  const VerificationItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.roleDetail,
    required this.location,
    required this.registrationType,
    required this.documentName,
    required this.documentUrl,
    required this.submissionDate,
    this.status = VerificationStatus.pending,
    this.rejectionReason,
  });

  VerificationItem copyWith({
    String? id,
    String? userId,
    String? userName,
    UserRole? userRole,
    String? roleDetail,
    String? location,
    String? registrationType,
    String? documentName,
    String? documentUrl,
    DateTime? submissionDate,
    VerificationStatus? status,
    String? rejectionReason,
  }) {
    return VerificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      roleDetail: roleDetail ?? this.roleDetail,
      location: location ?? this.location,
      registrationType: registrationType ?? this.registrationType,
      documentName: documentName ?? this.documentName,
      documentUrl: documentUrl ?? this.documentUrl,
      submissionDate: submissionDate ?? this.submissionDate,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole.name,
      'roleDetail': roleDetail,
      'location': location,
      'registrationType': registrationType,
      'documentName': documentName,
      'documentUrl': documentUrl,
      'submissionDate': submissionDate.toIso8601String(),
      'status': status.name,
      'rejectionReason': rejectionReason,
    };
  }

  factory VerificationItem.fromJson(Map<String, dynamic> json) {
    return VerificationItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userRole: UserRole.values.firstWhere(
        (e) => e.name == json['userRole'],
        orElse: () => UserRole.petani,
      ),
      roleDetail: json['roleDetail'] as String,
      location: json['location'] as String,
      registrationType: json['registrationType'] as String,
      documentName: json['documentName'] as String,
      documentUrl: json['documentUrl'] as String,
      submissionDate: json['submissionDate'] != null
          ? DateTime.parse(json['submissionDate'] as String)
          : DateTime.now(),
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VerificationStatus.pending,
      ),
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}

class DisputeItem {
  final String id;
  final String orderId;
  final String orderNumber;
  final String reporterName;
  final String reportedName;
  final String issueDescription;
  final DateTime reportedAt;
  final bool isResolved;
  final String? resolutionNotes;

  const DisputeItem({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.reporterName,
    required this.reportedName,
    required this.issueDescription,
    required this.reportedAt,
    this.isResolved = false,
    this.resolutionNotes,
  });

  DisputeItem copyWith({
    String? id,
    String? orderId,
    String? orderNumber,
    String? reporterName,
    String? reportedName,
    String? issueDescription,
    DateTime? reportedAt,
    bool? isResolved,
    String? resolutionNotes,
  }) {
    return DisputeItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      reporterName: reporterName ?? this.reporterName,
      reportedName: reportedName ?? this.reportedName,
      issueDescription: issueDescription ?? this.issueDescription,
      reportedAt: reportedAt ?? this.reportedAt,
      isResolved: isResolved ?? this.isResolved,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'orderNumber': orderNumber,
      'reporterName': reporterName,
      'reportedName': reportedName,
      'issueDescription': issueDescription,
      'reportedAt': reportedAt.toIso8601String(),
      'isResolved': isResolved,
      'resolutionNotes': resolutionNotes,
    };
  }

  factory DisputeItem.fromJson(Map<String, dynamic> json) {
    return DisputeItem(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String,
      reporterName: json['reporterName'] as String,
      reportedName: json['reportedName'] as String,
      issueDescription: json['issueDescription'] as String,
      reportedAt: json['reportedAt'] != null
          ? DateTime.parse(json['reportedAt'] as String)
          : DateTime.now(),
      isResolved: json['isResolved'] as bool? ?? false,
      resolutionNotes: json['resolutionNotes'] as String?,
    );
  }
}

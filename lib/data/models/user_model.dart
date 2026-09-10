enum UserRole { petani, pebisnis, admin }

enum VerificationStatus { verified, pending, rejected }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String? businessType; // Restoran, Distributor, Hotel, UMKM, Supermarket
  final String? farmLocation; // Malang, Jawa Timur, etc.
  final String? documentPath; // KTP or Business license
  final VerificationStatus verificationStatus;
  final String? avatarUrl;
  final double rating;
  final int totalTransactions;
  final DateTime joinedDate;
  final bool isProMember;
  final DateTime? subscriptionExpiry;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.businessType,
    this.farmLocation,
    this.documentPath,
    this.verificationStatus = VerificationStatus.pending,
    this.avatarUrl,
    this.rating = 5.0,
    this.totalTransactions = 0,
    required this.joinedDate,
    this.isProMember = false,
    this.subscriptionExpiry,
  });

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  String get roleDisplay {
    switch (role) {
      case UserRole.petani:
        return 'Petani';
      case UserRole.pebisnis:
        return 'Pebisnis (${businessType ?? 'Bisnis'})';
      case UserRole.admin:
        return 'Admin';
    }
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    String? businessType,
    String? farmLocation,
    String? documentPath,
    VerificationStatus? verificationStatus,
    String? avatarUrl,
    double? rating,
    int? totalTransactions,
    DateTime? joinedDate,
    bool? isProMember,
    DateTime? subscriptionExpiry,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      businessType: businessType ?? this.businessType,
      farmLocation: farmLocation ?? this.farmLocation,
      documentPath: documentPath ?? this.documentPath,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      joinedDate: joinedDate ?? this.joinedDate,
      isProMember: isProMember ?? this.isProMember,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.name,
      'businessType': businessType,
      'farmLocation': farmLocation,
      'documentPath': documentPath,
      'verificationStatus': verificationStatus.name,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'totalTransactions': totalTransactions,
      'joinedDate': joinedDate.toIso8601String(),
      'isProMember': isProMember,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final phoneVal = (json['phone'] as String?) ?? '';
    final emailVal = json['email'] as String?;
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: phoneVal,
      email: emailVal ?? (phoneVal.contains('@') ? phoneVal : null),
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.pebisnis,
      ),
      businessType: json['businessType'] as String?,
      farmLocation: json['farmLocation'] as String?,
      documentPath: json['documentPath'] as String?,
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == json['verificationStatus'],
        orElse: () => VerificationStatus.pending,
      ),
      avatarUrl: json['avatarUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTransactions: (json['totalTransactions'] as num?)?.toInt() ?? 0,
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'] as String)
          : DateTime.now(),
      isProMember: json['isProMember'] as bool? ?? false,
      subscriptionExpiry: json['subscriptionExpiry'] != null
          ? DateTime.tryParse(json['subscriptionExpiry'] as String)
          : null,
    );
  }
}

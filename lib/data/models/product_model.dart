class ProductModel {
  final String id;
  final String title;
  final String category; // Sayuran, Buah, Palawija, Karbohidrat, Rempah
  final String farmerId;
  final String farmerName;
  final String farmerLocation;
  final bool isFarmerVerified;
  final int pricePerKg;
  final int stockKg;
  final String qualityGrade; // Grade A, Grade B, Grade C
  final String harvestEstimate; // e.g. 20 Agustus 2026
  final String description;
  final String imageUrl;
  final int distanceKm;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final bool isPendingSync;

  const ProductModel({
    required this.id,
    required this.title,
    required this.category,
    required this.farmerId,
    required this.farmerName,
    required this.farmerLocation,
    this.isFarmerVerified = true,
    required this.pricePerKg,
    required this.stockKg,
    required this.qualityGrade,
    required this.harvestEstimate,
    required this.description,
    required this.imageUrl,
    this.distanceKm = 20,
    this.rating = 4.9,
    this.reviewCount = 18,
    required this.createdAt,
    this.isPendingSync = false,
  });

  ProductModel copyWith({
    String? id,
    String? title,
    String? category,
    String? farmerId,
    String? farmerName,
    String? farmerLocation,
    bool? isFarmerVerified,
    int? pricePerKg,
    int? stockKg,
    String? qualityGrade,
    String? harvestEstimate,
    String? description,
    String? imageUrl,
    int? distanceKm,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    bool? isPendingSync,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerLocation: farmerLocation ?? this.farmerLocation,
      isFarmerVerified: isFarmerVerified ?? this.isFarmerVerified,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      stockKg: stockKg ?? this.stockKg,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      harvestEstimate: harvestEstimate ?? this.harvestEstimate,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerLocation': farmerLocation,
      'isFarmerVerified': isFarmerVerified,
      'pricePerKg': pricePerKg,
      'stockKg': stockKg,
      'qualityGrade': qualityGrade,
      'harvestEstimate': harvestEstimate,
      'description': description,
      'imageUrl': imageUrl,
      'distanceKm': distanceKm,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'isPendingSync': isPendingSync,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      farmerId: json['farmerId'] as String,
      farmerName: json['farmerName'] as String,
      farmerLocation: json['farmerLocation'] as String,
      isFarmerVerified: json['isFarmerVerified'] as bool? ?? true,
      pricePerKg: (json['pricePerKg'] as num).toInt(),
      stockKg: (json['stockKg'] as num).toInt(),
      qualityGrade: json['qualityGrade'] as String,
      harvestEstimate: json['harvestEstimate'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      distanceKm: (json['distanceKm'] as num?)?.toInt() ?? 20,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 18,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isPendingSync: json['isPendingSync'] as bool? ?? false,
    );
  }
}

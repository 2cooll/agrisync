class ReviewItem {
  final String id;
  final String orderId;
  final String productId;
  final String productTitle;
  final String farmerId;
  final String farmerName;
  final String buyerId;
  final String buyerName;
  final String? buyerAvatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final int quantityKg;

  const ReviewItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productTitle,
    required this.farmerId,
    required this.farmerName,
    required this.buyerId,
    required this.buyerName,
    this.buyerAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.quantityKg = 50,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productTitle': productTitle,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerAvatarUrl': buyerAvatarUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'quantityKg': quantityKg,
    };
  }

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: json['id'] as String,
      orderId: json['orderId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productTitle: json['productTitle'] as String? ?? '',
      farmerId: json['farmerId'] as String? ?? '',
      farmerName: json['farmerName'] as String? ?? '',
      buyerId: json['buyerId'] as String? ?? '',
      buyerName: json['buyerName'] as String? ?? '',
      buyerAvatarUrl: json['buyerAvatarUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      quantityKg: (json['quantityKg'] as num?)?.toInt() ?? 50,
    );
  }
}

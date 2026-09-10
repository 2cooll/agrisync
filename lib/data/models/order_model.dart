enum OrderStatus {
  menungguPembayaran,
  diproses,
  dikirim,
  selesai,
  sengketa,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.menungguPembayaran:
        return 'Menunggu Pembayaran';
      case OrderStatus.diproses:
        return 'Diproses Penjual';
      case OrderStatus.dikirim:
        return 'Dalam Pengiriman';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.sengketa:
        return 'Dalam Sengketa';
    }
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String productId;
  final String productTitle;
  final String productImageUrl;
  final String farmerId;
  final String farmerName;
  final String farmerLocation;
  final String businessId;
  final String businessName;
  final String businessType;
  final int quantityKg;
  final int agreedPricePerKg;
  final int totalAmount;
  final int shippingFee;
  final int grandTotal;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final String? trackingNumber;
  final String deliveryAddress;
  final String? notes;
  final bool hasReviewed;
  final double? givenRating;
  final String? givenReview;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.productId,
    required this.productTitle,
    required this.productImageUrl,
    required this.farmerId,
    required this.farmerName,
    required this.farmerLocation,
    required this.businessId,
    required this.businessName,
    required this.businessType,
    required this.quantityKg,
    required this.agreedPricePerKg,
    required this.totalAmount,
    this.shippingFee = 0,
    required this.grandTotal,
    required this.paymentMethod,
    this.status = OrderStatus.diproses,
    required this.createdAt,
    this.trackingNumber,
    required this.deliveryAddress,
    this.notes,
    this.hasReviewed = false,
    this.givenRating,
    this.givenReview,
  });

  double get totalPrice => totalAmount.toDouble();

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? productId,
    String? productTitle,
    String? productImageUrl,
    String? farmerId,
    String? farmerName,
    String? farmerLocation,
    String? businessId,
    String? businessName,
    String? businessType,
    int? quantityKg,
    int? agreedPricePerKg,
    int? totalAmount,
    int? shippingFee,
    int? grandTotal,
    String? paymentMethod,
    OrderStatus? status,
    DateTime? createdAt,
    String? trackingNumber,
    String? deliveryAddress,
    String? notes,
    bool? hasReviewed,
    double? givenRating,
    String? givenReview,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerLocation: farmerLocation ?? this.farmerLocation,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      quantityKg: quantityKg ?? this.quantityKg,
      agreedPricePerKg: agreedPricePerKg ?? this.agreedPricePerKg,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      grandTotal: grandTotal ?? this.grandTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      hasReviewed: hasReviewed ?? this.hasReviewed,
      givenRating: givenRating ?? this.givenRating,
      givenReview: givenReview ?? this.givenReview,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'productId': productId,
      'productTitle': productTitle,
      'productImageUrl': productImageUrl,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerLocation': farmerLocation,
      'businessId': businessId,
      'businessName': businessName,
      'businessType': businessType,
      'quantityKg': quantityKg,
      'agreedPricePerKg': agreedPricePerKg,
      'totalAmount': totalAmount,
      'shippingFee': shippingFee,
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'trackingNumber': trackingNumber,
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'hasReviewed': hasReviewed,
      'givenRating': givenRating,
      'givenReview': givenReview,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      productId: json['productId'] as String,
      productTitle: json['productTitle'] as String,
      productImageUrl: json['productImageUrl'] as String,
      farmerId: json['farmerId'] as String,
      farmerName: json['farmerName'] as String,
      farmerLocation: json['farmerLocation'] as String,
      businessId: json['businessId'] as String,
      businessName: json['businessName'] as String,
      businessType: json['businessType'] as String,
      quantityKg: (json['quantityKg'] as num).toInt(),
      agreedPricePerKg: (json['agreedPricePerKg'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toInt(),
      shippingFee: (json['shippingFee'] as num?)?.toInt() ?? 0,
      grandTotal: (json['grandTotal'] as num).toInt(),
      paymentMethod: json['paymentMethod'] as String,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.diproses,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      trackingNumber: json['trackingNumber'] as String?,
      deliveryAddress: json['deliveryAddress'] as String,
      notes: json['notes'] as String?,
      hasReviewed: json['hasReviewed'] as bool? ?? false,
      givenRating: (json['givenRating'] as num?)?.toDouble(),
      givenReview: json['givenReview'] as String?,
    );
  }
}

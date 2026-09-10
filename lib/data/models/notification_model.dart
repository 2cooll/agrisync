enum NotificationType {
  order,
  negotiation,
  chat,
  harvest,
  priceTrend,
  promotion,
  system,
}

enum NotificationCategory {
  all,
  ordersPayments,
  promosNews,
  systemInfo,
}

class NotificationModel {
  final String id;
  final String recipientUserId;
  final String? senderId;
  final String? senderName;
  final String title;
  final String message;
  final NotificationType type;
  final String? referenceId; // orderId or threadId
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.recipientUserId,
    this.senderId,
    this.senderName,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? recipientUserId,
    String? senderId,
    String? senderName,
    String? title,
    String? message,
    NotificationType? type,
    String? referenceId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientUserId': recipientUserId,
      'senderId': senderId,
      'senderName': senderName,
      'title': title,
      'message': message,
      'type': type.name,
      'referenceId': referenceId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      recipientUserId: json['recipientUserId'] as String,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      referenceId: json['referenceId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

extension NotificationModelCategoryExtension on NotificationModel {
  NotificationCategory get category {
    switch (type) {
      case NotificationType.order:
      case NotificationType.negotiation:
      case NotificationType.chat:
        return NotificationCategory.ordersPayments;
      case NotificationType.promotion:
      case NotificationType.priceTrend:
      case NotificationType.harvest:
        return NotificationCategory.promosNews;
      case NotificationType.system:
        return NotificationCategory.systemInfo;
    }
  }

  String get categoryLabel {
    switch (category) {
      case NotificationCategory.ordersPayments:
        return 'Pesanan & Bayar';
      case NotificationCategory.promosNews:
        return 'Promo & Berita';
      case NotificationCategory.systemInfo:
        return 'Info Sistem';
      case NotificationCategory.all:
        return 'Semua';
    }
  }
}

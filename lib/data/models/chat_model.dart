enum NegotiationStatus { pending, accepted, rejected, countered }

class NegotiationOffer {
  final String id;
  final int offeredPrice; // per kg
  final int quantityKg;
  final int totalAmount;
  final NegotiationStatus status;
  final String senderId;
  final String senderName;
  final DateTime timestamp;

  const NegotiationOffer({
    required this.id,
    required this.offeredPrice,
    required this.quantityKg,
    required this.totalAmount,
    this.status = NegotiationStatus.pending,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  NegotiationOffer copyWith({
    String? id,
    int? offeredPrice,
    int? quantityKg,
    int? totalAmount,
    NegotiationStatus? status,
    String? senderId,
    String? senderName,
    DateTime? timestamp,
  }) {
    return NegotiationOffer(
      id: id ?? this.id,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      quantityKg: quantityKg ?? this.quantityKg,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offeredPrice': offeredPrice,
      'quantityKg': quantityKg,
      'totalAmount': totalAmount,
      'status': status.name,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NegotiationOffer.fromJson(Map<String, dynamic> json) {
    return NegotiationOffer(
      id: json['id'] as String,
      offeredPrice: (json['offeredPrice'] as num).toInt(),
      quantityKg: (json['quantityKg'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toInt(),
      status: NegotiationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NegotiationStatus.pending,
      ),
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isFromPebisnis;
  final NegotiationOffer? offer;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isFromPebisnis,
    this.offer,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isFromPebisnis': isFromPebisnis,
      'offer': offer?.toJson(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isFromPebisnis: json['isFromPebisnis'] as bool? ?? false,
      offer: json['offer'] != null
          ? NegotiationOffer.fromJson(json['offer'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ChatThread {
  final String id;
  final String buyerId;
  final String buyerName;
  final String farmerId;
  final String farmerName;
  final List<String> participantIds;
  final String otherUserId;
  final String otherUserName;
  final String otherUserRole; // Petani or Pebisnis
  final String otherUserLocation;
  final bool isVerified;
  final String? avatarUrl;
  final String productId;
  final String productTitle;
  final int productPrice;
  final String productImageUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final NegotiationOffer? activeOffer;
  final List<ChatMessage> messages;

  const ChatThread({
    required this.id,
    this.buyerId = 'usr_pebisnis_1',
    this.buyerName = 'Restoran Bintang',
    this.farmerId = 'usr_petani_1',
    this.farmerName = 'Pak Eko',
    this.participantIds = const ['usr_pebisnis_1', 'usr_petani_1'],
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserRole,
    required this.otherUserLocation,
    this.isVerified = true,
    this.avatarUrl,
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    required this.productImageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.activeOffer,
    required this.messages,
  });

  String getOtherUserId(String currentUserId) {
    if (currentUserId == buyerId) return farmerId;
    if (currentUserId == farmerId) return buyerId;
    return otherUserId;
  }

  String getOtherUserName(String currentUserId) {
    if (currentUserId == buyerId) return farmerName.isNotEmpty ? farmerName : otherUserName;
    if (currentUserId == farmerId) return buyerName.isNotEmpty ? buyerName : otherUserName;
    return otherUserName;
  }

  String getOtherUserRole(String currentUserId) {
    if (currentUserId == buyerId) return 'Petani';
    if (currentUserId == farmerId) return 'Pebisnis';
    return otherUserRole;
  }

  bool isParticipant(String userId) {
    return participantIds.contains(userId) ||
        buyerId == userId ||
        farmerId == userId ||
        otherUserId == userId;
  }

  ChatThread copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? farmerId,
    String? farmerName,
    List<String>? participantIds,
    String? otherUserId,
    String? otherUserName,
    String? otherUserRole,
    String? otherUserLocation,
    bool? isVerified,
    String? avatarUrl,
    String? productId,
    String? productTitle,
    int? productPrice,
    String? productImageUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    NegotiationOffer? activeOffer,
    List<ChatMessage>? messages,
  }) {
    return ChatThread(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      participantIds: participantIds ?? this.participantIds,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserRole: otherUserRole ?? this.otherUserRole,
      otherUserLocation: otherUserLocation ?? this.otherUserLocation,
      isVerified: isVerified ?? this.isVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productPrice: productPrice ?? this.productPrice,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      activeOffer: activeOffer ?? this.activeOffer,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'participantIds': participantIds,
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserRole': otherUserRole,
      'otherUserLocation': otherUserLocation,
      'isVerified': isVerified,
      'avatarUrl': avatarUrl,
      'productId': productId,
      'productTitle': productTitle,
      'productPrice': productPrice,
      'productImageUrl': productImageUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'activeOffer': activeOffer?.toJson(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    final otherUserId = json['otherUserId'] as String? ?? '';
    final buyerId = json['buyerId'] as String? ?? 'usr_pebisnis_1';
    final farmerId = json['farmerId'] as String? ?? (otherUserId.isNotEmpty ? otherUserId : 'usr_petani_1');
    final pIds = (json['participantIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [buyerId, farmerId];

    return ChatThread(
      id: json['id'] as String,
      buyerId: buyerId,
      buyerName: json['buyerName'] as String? ?? 'Pembeli',
      farmerId: farmerId,
      farmerName: json['farmerName'] as String? ?? (json['otherUserName'] as String? ?? 'Petani'),
      participantIds: pIds,
      otherUserId: otherUserId.isNotEmpty ? otherUserId : farmerId,
      otherUserName: json['otherUserName'] as String? ?? (json['farmerName'] as String? ?? ''),
      otherUserRole: json['otherUserRole'] as String? ?? 'Petani',
      otherUserLocation: json['otherUserLocation'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? true,
      avatarUrl: json['avatarUrl'] as String?,
      productId: json['productId'] as String,
      productTitle: json['productTitle'] as String,
      productPrice: (json['productPrice'] as num).toInt(),
      productImageUrl: json['productImageUrl'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : DateTime.now(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      activeOffer: json['activeOffer'] != null
          ? NegotiationOffer.fromJson(json['activeOffer'] as Map<String, dynamic>)
          : null,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

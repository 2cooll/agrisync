import '../models/chat_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../mock_data.dart';
import 'local_storage_service.dart';

abstract class IChatService {
  List<ChatThread> getChatThreads();
  List<ChatThread> getChatThreadsForUser(String userId);
  ChatThread? getChatThread(String threadId);
  ChatThread getOrCreateThreadForProduct(ProductModel product, UserModel currentUser);
  void sendChatMessage(String threadId, String text, UserModel currentUser);
  void submitOffer(String threadId, int pricePerKg, int quantityKg, UserModel currentUser);
  void counterOffer(String threadId, int counterPricePerKg, int quantityKg, UserModel currentUser);
  void acceptOffer(String threadId, UserModel currentUser);
  void rejectOffer(String threadId, UserModel currentUser, {String? reason});
}

class MockChatService implements IChatService {
  final LocalStorageService? _storage;
  late List<ChatThread> _chatThreads;

  MockChatService({LocalStorageService? storage, List<ChatThread>? initialThreads})
      : _storage = storage {
    _chatThreads = initialThreads ?? (_storage?.loadChatThreads() ?? MockData.getInitialChatThreads());
  }

  @override
  List<ChatThread> getChatThreads() => List.unmodifiable(_chatThreads);

  @override
  List<ChatThread> getChatThreadsForUser(String userId) {
    return List.unmodifiable(
      _chatThreads.where((t) => t.isParticipant(userId)).toList(),
    );
  }

  @override
  ChatThread? getChatThread(String threadId) {
    try {
      return _chatThreads.firstWhere((t) => t.id == threadId);
    } catch (_) {
      return null;
    }
  }

  @override
  ChatThread getOrCreateThreadForProduct(ProductModel product, UserModel currentUser) {
    final existingIndex = _chatThreads.indexWhere(
      (t) => t.productId == product.id && t.isParticipant(currentUser.id),
    );
    if (existingIndex != -1) {
      return _chatThreads[existingIndex];
    }

    final isBuyer = currentUser.role == UserRole.pebisnis;
    final buyerId = isBuyer ? currentUser.id : 'usr_buyer_${DateTime.now().millisecondsSinceEpoch}';
    final buyerName = isBuyer ? currentUser.name : 'Pembeli';
    final farmerId = product.farmerId;
    final farmerName = product.farmerName;

    final newThread = ChatThread(
      id: 'chat_${currentUser.id}_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      buyerId: buyerId,
      buyerName: buyerName,
      farmerId: farmerId,
      farmerName: farmerName,
      participantIds: [buyerId, farmerId],
      otherUserId: isBuyer ? farmerId : buyerId,
      otherUserName: isBuyer ? farmerName : buyerName,
      otherUserRole: isBuyer ? 'Petani' : 'Pebisnis',
      otherUserLocation: product.farmerLocation,
      isVerified: product.isFarmerVerified,
      productId: product.id,
      productTitle: product.title,
      productPrice: product.pricePerKg,
      productImageUrl: product.imageUrl,
      lastMessage: 'Halo, saya tertarik dengan produk ${product.title}',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      messages: [
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: currentUser.id,
          senderName: currentUser.name,
          text: 'Halo, saya tertarik dengan produk ${product.title}',
          timestamp: DateTime.now(),
          isFromPebisnis: currentUser.role == UserRole.pebisnis,
        ),
      ],
    );

    _chatThreads.insert(0, newThread);
    _storage?.saveChatThreads(_chatThreads);
    return newThread;
  }

  @override
  void sendChatMessage(String threadId, String text, UserModel currentUser) {
    final index = _chatThreads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      final thread = _chatThreads[index];
      final newMsg = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: currentUser.id,
        senderName: currentUser.name,
        text: text,
        timestamp: DateTime.now(),
        isFromPebisnis: currentUser.role == UserRole.pebisnis,
      );

      final updatedMessages = List<ChatMessage>.from(thread.messages)..add(newMsg);
      _chatThreads[index] = thread.copyWith(
        messages: updatedMessages,
        lastMessage: text,
        lastMessageTime: DateTime.now(),
      );
      _storage?.saveChatThreads(_chatThreads);
    }
  }

  @override
  void submitOffer(String threadId, int pricePerKg, int quantityKg, UserModel currentUser) {
    final index = _chatThreads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      final thread = _chatThreads[index];
      final total = pricePerKg * quantityKg;
      final offer = NegotiationOffer(
        id: 'off_${DateTime.now().millisecondsSinceEpoch}',
        offeredPrice: pricePerKg,
        quantityKg: quantityKg,
        totalAmount: total,
        status: NegotiationStatus.pending,
        senderId: currentUser.id,
        senderName: currentUser.name,
        timestamp: DateTime.now(),
      );

      final offerMsg = ChatMessage(
        id: 'msg_off_${DateTime.now().millisecondsSinceEpoch}',
        senderId: currentUser.id,
        senderName: currentUser.name,
        text: '📝 Mengajukan penawaran: Rp$pricePerKg/kg untuk $quantityKg kg (Total: Rp$total)',
        timestamp: DateTime.now(),
        isFromPebisnis: currentUser.role == UserRole.pebisnis,
        offer: offer,
      );

      final updatedMessages = List<ChatMessage>.from(thread.messages)..add(offerMsg);
      _chatThreads[index] = thread.copyWith(
        activeOffer: offer,
        messages: updatedMessages,
        lastMessage: 'Penawaran baru: Rp$pricePerKg/kg ($quantityKg kg)',
        lastMessageTime: DateTime.now(),
      );
      _storage?.saveChatThreads(_chatThreads);
    }
  }

  @override
  void counterOffer(String threadId, int counterPricePerKg, int quantityKg, UserModel currentUser) {
    final index = _chatThreads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      final thread = _chatThreads[index];
      final total = counterPricePerKg * quantityKg;
      final newOffer = NegotiationOffer(
        id: 'off_counter_${DateTime.now().millisecondsSinceEpoch}',
        offeredPrice: counterPricePerKg,
        quantityKg: quantityKg,
        totalAmount: total,
        status: NegotiationStatus.pending,
        senderId: currentUser.id,
        senderName: currentUser.name,
        timestamp: DateTime.now(),
      );

      final counterMsg = ChatMessage(
        id: 'msg_counter_${DateTime.now().millisecondsSinceEpoch}',
        senderId: currentUser.id,
        senderName: currentUser.name,
        text: '🔄 Menawar balik: Rp$counterPricePerKg/kg untuk $quantityKg kg (Total: Rp$total)',
        timestamp: DateTime.now(),
        isFromPebisnis: currentUser.role == UserRole.pebisnis,
        offer: newOffer,
      );

      final updatedMessages = List<ChatMessage>.from(thread.messages)..add(counterMsg);
      _chatThreads[index] = thread.copyWith(
        activeOffer: newOffer,
        messages: updatedMessages,
        lastMessage: 'Tawar balik: Rp$counterPricePerKg/kg ($quantityKg kg)',
        lastMessageTime: DateTime.now(),
      );
      _storage?.saveChatThreads(_chatThreads);
    }
  }

  @override
  void acceptOffer(String threadId, UserModel currentUser) {
    final index = _chatThreads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      final thread = _chatThreads[index];
      if (thread.activeOffer != null) {
        final updatedOffer = thread.activeOffer!.copyWith(
          status: NegotiationStatus.accepted,
        );

        final acceptMsg = ChatMessage(
          id: 'msg_acc_${DateTime.now().millisecondsSinceEpoch}',
          senderId: currentUser.id,
          senderName: currentUser.name,
          text: '🤝 Penawaran Rp${updatedOffer.offeredPrice}/kg (${updatedOffer.quantityKg} kg) disetujui! Total: Rp${updatedOffer.totalAmount}. Silakan lanjutkan ke pembayaran.',
          timestamp: DateTime.now(),
          isFromPebisnis: currentUser.role == UserRole.pebisnis,
          offer: updatedOffer,
        );

        final updatedMessages = List<ChatMessage>.from(thread.messages)..add(acceptMsg);
        _chatThreads[index] = thread.copyWith(
          activeOffer: updatedOffer,
          messages: updatedMessages,
          lastMessage: 'Penawaran disepakati Rp${updatedOffer.offeredPrice}/kg',
          lastMessageTime: DateTime.now(),
        );
        _storage?.saveChatThreads(_chatThreads);
      }
    }
  }

  @override
  void rejectOffer(String threadId, UserModel currentUser, {String? reason}) {
    final index = _chatThreads.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      final thread = _chatThreads[index];
      if (thread.activeOffer != null) {
        final updatedOffer = thread.activeOffer!.copyWith(
          status: NegotiationStatus.rejected,
        );

        final reasonText = (reason != null && reason.trim().isNotEmpty) ? ' (Alasan: $reason)' : '';
        final rejectMsg = ChatMessage(
          id: 'msg_rej_${DateTime.now().millisecondsSinceEpoch}',
          senderId: currentUser.id,
          senderName: currentUser.name,
          text: '❌ Menolak penawaran Rp${thread.activeOffer!.offeredPrice}/kg$reasonText. Anda dapat mengajukan harga kembali.',
          timestamp: DateTime.now(),
          isFromPebisnis: currentUser.role == UserRole.pebisnis,
          offer: updatedOffer,
        );

        final updatedMessages = List<ChatMessage>.from(thread.messages)..add(rejectMsg);
        _chatThreads[index] = thread.copyWith(
          activeOffer: updatedOffer,
          messages: updatedMessages,
          lastMessage: 'Penawaran ditolak',
          lastMessageTime: DateTime.now(),
        );
        _storage?.saveChatThreads(_chatThreads);
      }
    }
  }
}

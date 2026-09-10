import '../models/chat_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';

abstract class ChatRepository {
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

class ChatRepositoryImpl implements ChatRepository {
  final IChatService _chatService;

  ChatRepositoryImpl({IChatService? chatService})
      : _chatService = chatService ?? MockChatService();

  @override
  List<ChatThread> getChatThreads() => _chatService.getChatThreads();

  @override
  List<ChatThread> getChatThreadsForUser(String userId) =>
      _chatService.getChatThreadsForUser(userId);

  @override
  ChatThread? getChatThread(String threadId) => _chatService.getChatThread(threadId);

  @override
  ChatThread getOrCreateThreadForProduct(ProductModel product, UserModel currentUser) =>
      _chatService.getOrCreateThreadForProduct(product, currentUser);

  @override
  void sendChatMessage(String threadId, String text, UserModel currentUser) =>
      _chatService.sendChatMessage(threadId, text, currentUser);

  @override
  void submitOffer(String threadId, int pricePerKg, int quantityKg, UserModel currentUser) =>
      _chatService.submitOffer(threadId, pricePerKg, quantityKg, currentUser);

  @override
  void counterOffer(String threadId, int counterPricePerKg, int quantityKg, UserModel currentUser) =>
      _chatService.counterOffer(threadId, counterPricePerKg, quantityKg, currentUser);

  @override
  void acceptOffer(String threadId, UserModel currentUser) =>
      _chatService.acceptOffer(threadId, currentUser);

  @override
  void rejectOffer(String threadId, UserModel currentUser, {String? reason}) =>
      _chatService.rejectOffer(threadId, currentUser, reason: reason);
}

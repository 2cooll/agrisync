import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/order_service.dart';

abstract class OrderRepository {
  List<OrderModel> getOrders();
  OrderModel? getOrderById(String orderId);
  OrderModel createOrder({
    required ProductModel product,
    required UserModel currentUser,
    required int quantityKg,
    required int agreedPricePerKg,
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
  });
  void updateOrderStatus(String orderId, OrderStatus status);
  void submitOrderReview(String orderId, double rating, String review);
}

class OrderRepositoryImpl implements OrderRepository {
  final IOrderService _orderService;

  OrderRepositoryImpl({IOrderService? orderService})
      : _orderService = orderService ?? MockOrderService();

  @override
  List<OrderModel> getOrders() => _orderService.getOrders();

  @override
  OrderModel? getOrderById(String orderId) => _orderService.getOrderById(orderId);

  @override
  OrderModel createOrder({
    required ProductModel product,
    required UserModel currentUser,
    required int quantityKg,
    required int agreedPricePerKg,
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
  }) =>
      _orderService.createOrder(
        product: product,
        currentUser: currentUser,
        quantityKg: quantityKg,
        agreedPricePerKg: agreedPricePerKg,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        notes: notes,
      );

  @override
  void updateOrderStatus(String orderId, OrderStatus status) =>
      _orderService.updateOrderStatus(orderId, status);

  @override
  void submitOrderReview(String orderId, double rating, String review) =>
      _orderService.submitOrderReview(orderId, rating, review);
}

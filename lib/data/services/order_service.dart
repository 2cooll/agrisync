import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../mock_data.dart';
import 'local_storage_service.dart';

abstract class IOrderService {
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

class MockOrderService implements IOrderService {
  final LocalStorageService? _storage;
  late List<OrderModel> _orders;

  MockOrderService({LocalStorageService? storage, List<OrderModel>? initialOrders})
      : _storage = storage {
    _orders = initialOrders ?? (_storage?.loadOrders() ?? MockData.getInitialOrders());
  }

  @override
  List<OrderModel> getOrders() => List.unmodifiable(_orders);

  @override
  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  OrderModel createOrder({
    required ProductModel product,
    required UserModel currentUser,
    required int quantityKg,
    required int agreedPricePerKg,
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
  }) {
    final total = quantityKg * agreedPricePerKg;
    final newOrder = OrderModel(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber:
          'AGRI-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${_orders.length + 101}',
      productId: product.id,
      productTitle: product.title,
      productImageUrl: product.imageUrl,
      farmerId: product.farmerId,
      farmerName: product.farmerName,
      farmerLocation: product.farmerLocation,
      businessId: currentUser.id,
      businessName: currentUser.name,
      businessType: currentUser.businessType ?? 'Restoran',
      quantityKg: quantityKg,
      agreedPricePerKg: agreedPricePerKg,
      totalAmount: total,
      shippingFee: 0,
      grandTotal: total,
      paymentMethod: paymentMethod,
      status: OrderStatus.menungguPembayaran,
      createdAt: DateTime.now(),
      deliveryAddress: deliveryAddress,
      notes: notes,
    );

    _orders.insert(0, newOrder);
    _storage?.saveOrders(_orders);
    return newOrder;
  }

  @override
  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      _storage?.saveOrders(_orders);
    }
  }

  @override
  void submitOrderReview(String orderId, double rating, String review) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        hasReviewed: true,
        givenRating: rating,
        givenReview: review,
        status: OrderStatus.selesai,
      );
      _storage?.saveOrders(_orders);
    }
  }
}

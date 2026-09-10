import '../models/product_model.dart';
import '../mock_data.dart';
import 'local_storage_service.dart';

abstract class IProductService {
  List<ProductModel> getProducts();
  void addProduct(ProductModel product);
  void updateProduct(ProductModel updated);
  void deleteProduct(String id);
  void deleteProductsByFarmer(String farmerId);
  ProductModel? getProductById(String id);
}

class MockProductService implements IProductService {
  final LocalStorageService? _storage;
  late List<ProductModel> _products;

  MockProductService({LocalStorageService? storage, List<ProductModel>? initialProducts})
      : _storage = storage {
    _products = initialProducts ?? (_storage?.loadProducts() ?? MockData.getInitialProducts());
  }

  @override
  List<ProductModel> getProducts() => List.unmodifiable(_products);

  @override
  void addProduct(ProductModel product) {
    _products.insert(0, product);
    _storage?.saveProducts(_products);
  }

  @override
  void updateProduct(ProductModel updated) {
    final index = _products.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _products[index] = updated;
      _storage?.saveProducts(_products);
    }
  }

  @override
  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    _storage?.saveProducts(_products);
  }

  @override
  void deleteProductsByFarmer(String farmerId) {
    _products.removeWhere((p) => p.farmerId == farmerId);
    _storage?.saveProducts(_products);
  }

  @override
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

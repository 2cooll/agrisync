import '../models/product_model.dart';
import '../services/product_service.dart';

abstract class ProductRepository {
  List<ProductModel> getProducts();
  List<ProductModel> getFilteredProducts({
    String? category,
    String searchQuery = '',
    double minPrice = 0,
    double maxPrice = 100000,
    double minStock = 0,
    double maxStock = 5000,
    String quality = 'Semua',
    String location = '',
  });
  List<ProductModel> getFarmerProducts(String currentUserId);
  void addProduct(ProductModel product);
  void updateProduct(ProductModel updated);
  void deleteProduct(String id);
  void deleteProductsByFarmer(String farmerId);
  ProductModel? getProductById(String id);
}

class ProductRepositoryImpl implements ProductRepository {
  final IProductService _productService;

  ProductRepositoryImpl({IProductService? productService})
      : _productService = productService ?? MockProductService();

  @override
  List<ProductModel> getProducts() => _productService.getProducts();

  @override
  List<ProductModel> getFilteredProducts({
    String? category,
    String searchQuery = '',
    double minPrice = 0,
    double maxPrice = 100000,
    double minStock = 0,
    double maxStock = 5000,
    String quality = 'Semua',
    String location = '',
  }) {
    return _productService.getProducts().where((p) {
      // Saring produk yang stoknya 0 atau habis
      if (p.stockKg <= 0) {
        return false;
      }
      if (category != null &&
          category != 'Semua' &&
          p.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchTitle = p.title.toLowerCase().contains(query);
        final matchFarmer = p.farmerName.toLowerCase().contains(query);
        final matchLoc = p.farmerLocation.toLowerCase().contains(query);
        final matchCat = p.category.toLowerCase().contains(query);
        if (!matchTitle && !matchFarmer && !matchLoc && !matchCat) return false;
      }
      if (p.pricePerKg < minPrice || p.pricePerKg > maxPrice) {
        return false;
      }
      if (p.stockKg < minStock || p.stockKg > maxStock) {
        return false;
      }
      if (quality != 'Semua' && p.qualityGrade != quality) {
        return false;
      }
      if (location.isNotEmpty &&
          !p.farmerLocation.toLowerCase().contains(location.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  List<ProductModel> getFarmerProducts(String currentUserId) {
    return _productService
        .getProducts()
        .where((p) => p.farmerId == currentUserId)
        .toList();
  }

  @override
  void addProduct(ProductModel product) => _productService.addProduct(product);

  @override
  void updateProduct(ProductModel updated) => _productService.updateProduct(updated);

  @override
  void deleteProduct(String id) => _productService.deleteProduct(id);

  @override
  void deleteProductsByFarmer(String farmerId) => _productService.deleteProductsByFarmer(farmerId);

  @override
  ProductModel? getProductById(String id) => _productService.getProductById(id);
}

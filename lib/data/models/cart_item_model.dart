import 'product_model.dart';

class CartItem {
  final ProductModel product;
  int quantityKg;
  String? notes;

  CartItem({
    required this.product,
    required this.quantityKg,
    this.notes,
  });

  int get totalPrice => product.pricePerKg * quantityKg;

  CartItem copyWith({
    ProductModel? product,
    int? quantityKg,
    String? notes,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantityKg: quantityKg ?? this.quantityKg,
      notes: notes ?? this.notes,
    );
  }
}

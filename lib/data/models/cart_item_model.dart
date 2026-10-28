import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  List<String> customizations;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    List<String>? customizations,
  }) : customizations = customizations ?? [];

  double get itemTotal => product.price * quantity;

  Map<String, dynamic> toServerJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'customizations': customizations,
    };
  }
}

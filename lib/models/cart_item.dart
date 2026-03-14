import 'product_item.dart';

class CartItem {
  CartItem({
    required this.product,
    this.quantity = 1,
    this.size = 'M',
    this.color = 'Default',
    this.isSelected = true,
  });

  final ProductItem product;
  int quantity;
  String size;
  String color;
  bool isSelected;

  double get totalPrice => product.price * quantity;
}

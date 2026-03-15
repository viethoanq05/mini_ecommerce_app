/// Represents an item in the shopping cart used for checkout calculation.
class CartItem {
  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.size,
    required this.color,
  });

  final String productId;
  final String name;
  final double price;
  int quantity;
  final String image;
  final String size;
  final String color;

  double get subtotal => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

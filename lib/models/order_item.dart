class OrderItem {
  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  final String productId;
  final int quantity;
  final double price;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

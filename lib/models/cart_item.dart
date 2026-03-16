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

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'size': size,
      'color': color,
      'isSelected': isSelected,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productRaw = json['product'];
    final productMap = productRaw is Map
        ? Map<String, dynamic>.from(productRaw)
        : <String, dynamic>{};

    final safeProductJson = <String, dynamic>{
      'id': productMap['id'] ?? 'unknown',
      'title': productMap['title'] ?? productMap['name'] ?? 'Unknown product',
      'image': productMap['image'] ?? productMap['imageUrl'] ?? '',
      'price': productMap['price'] ?? 0,
      'currency': productMap['currency'] ?? 'VND',
      'soldCount': productMap['soldCount'] ?? 0,
      'tags': productMap['tags'] ?? const <String>[],
    };

    return CartItem(
      product: ProductItem.fromJson(safeProductJson),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      size: json['size']?.toString() ?? 'M',
      color: json['color']?.toString() ?? 'Default',
      isSelected: json['isSelected'] as bool? ?? true,
    );
  }
}

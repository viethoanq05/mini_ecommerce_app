import 'package:flutter/foundation.dart';
import '../models/product.dart';

/// Đại diện cho một sản phẩm trong giỏ hàng (kèm size, màu, số lượng).
class CartItem {
  final Product product;
  final String size;
  final String color;
  final int quantity;

  const CartItem({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) => CartItem(
    product: product,
    size: size,
    color: color,
    quantity: quantity ?? this.quantity,
  );
}

/// Quản lý state giỏ hàng toàn ứng dụng.
class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  /// Tổng số lượng sản phẩm trong giỏ.
  int get cartCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Thêm sản phẩm vào giỏ. Nếu đã có (cùng id + size + màu), tăng số lượng.
  void addToCart(Product product, String size, String color, int quantity) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.size == size &&
          item.color == color,
    );

    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          product: product,
          size: size,
          color: color,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  /// Xóa sản phẩm khỏi giỏ theo productId.
  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }
}

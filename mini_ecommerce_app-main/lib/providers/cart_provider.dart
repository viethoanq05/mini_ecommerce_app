import 'package:flutter/foundation.dart';

import '../models/product.dart';

/// Đại diện một mặt hàng trong giỏ hàng
class CartItem {
  CartItem({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
  });

  final Product product;
  final String size;
  final String color;
  int quantity;
}

/// Quản lý trạng thái giỏ hàng toàn ứng dụng với ChangeNotifier
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  /// Tổng số lượng tất cả sản phẩm trong giỏ
  int get cartCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Thêm sản phẩm vào giỏ; nếu trùng (id + size + màu) thì cộng dồn số lượng
  void addToCart(
    Product product, {
    required String size,
    required String color,
    required int quantity,
  }) {
    final idx = _items.indexWhere(
      (e) => e.product.id == product.id && e.size == size && e.color == color,
    );

    if (idx >= 0) {
      _items[idx].quantity += quantity;
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

  /// Xoá toàn bộ dòng sản phẩm theo productId
  void removeFromCart(String productId) {
    _items.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }
}

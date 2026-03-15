import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Quản lý trạng thái giỏ hàng toàn ứng dụng với [ChangeNotifier].
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
      (e) =>
          e.productId == product.id && e.size == size && e.color == color,
    );

    if (idx >= 0) {
      _items[idx].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          productId: product.id,
          name: product.name,
          price: product.priceOf(size, color),
          quantity: quantity,
          image: product.images.first,
          size: size,
          color: color,
        ),
      );
    }
    notifyListeners();
  }

  /// Cập nhật số lượng cho một mặt hàng trong giỏ.
  void updateQuantity({
    required String productId,
    required String size,
    required String color,
    required int quantity,
  }) {
    final idx = _items.indexWhere((e) =>
        e.productId == productId && e.size == size && e.color == color);
    if (idx >= 0) {
      if (quantity <= 0) {
        _items.removeAt(idx);
      } else {
        _items[idx] = CartItem(
          productId: _items[idx].productId,
          name: _items[idx].name,
          price: _items[idx].price,
          quantity: quantity,
          image: _items[idx].image,
          size: _items[idx].size,
          color: _items[idx].color,
        );
      }
      notifyListeners();
    }
  }

  /// Xoá toàn bộ dòng sản phẩm theo productId
  void removeFromCart(String productId) {
    _items.removeWhere((e) => e.productId == productId);
    notifyListeners();
  }

  /// Xoá toàn bộ giỏ hàng
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

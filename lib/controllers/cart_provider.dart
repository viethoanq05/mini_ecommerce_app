import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.where((item) => item.isSelected).fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  bool get isSelectAll {
    if (_items.isEmpty) return false;
    return _items.every((item) => item.isSelected);
  }

  void addItem(ProductItem product, {String size = 'M', String color = 'Mặc định'}) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id && item.size == size && item.color == color,
    );

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(
        product: product,
        size: size,
        color: color,
      ));
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateQuantity(CartItem item, int delta) {
    final newQuantity = item.quantity + delta;
    if (newQuantity <= 0) {
      // Handled by UI to show confirmation dialog
      return;
    }
    item.quantity = newQuantity;
    notifyListeners();
  }

  void toggleSelection(CartItem item) {
    item.isSelected = !item.isSelected;
    notifyListeners();
  }

  void toggleSelectAll(bool selected) {
    for (var item in _items) {
      item.isSelected = selected;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Helper to add mock data for testing
  void addMockItems(List<ProductItem> products) {
    for (var i = 0; i < products.length && i < 3; i++) {
       _items.add(CartItem(
        product: products[i],
        quantity: i + 1,
        size: i == 0 ? 'S' : (i == 1 ? 'M' : 'L'),
        color: i == 0 ? 'Đỏ' : (i == 1 ? 'Xanh' : 'Đen'),
      ));
    }
    notifyListeners();
  }
}

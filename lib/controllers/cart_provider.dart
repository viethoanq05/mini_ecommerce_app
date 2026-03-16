import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/product_item.dart';

class CartProvider with ChangeNotifier {
  static const String _storageKey = 'offline_cart_items_v1';

  final List<CartItem> _items = [];
  bool _isLoaded = false;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoaded => _isLoaded;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool get isSelectAll {
    if (_items.isEmpty) return false;
    return _items.every((item) => item.isSelected);
  }

  Future<void> load() async {
    if (_isLoaded) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _items
            ..clear()
            ..addAll(
              decoded.whereType<Map>().map(
                (e) => CartItem.fromJson(Map<String, dynamic>.from(e)),
              ),
            );
        }
      }
    } catch (_) {
      // Fallback: keep cart empty if local cache is invalid/corrupted.
      _items.clear();
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // Ignore persistence errors to avoid breaking user flow.
    }
  }

  void addItem(
    ProductItem product, {
    String size = 'M',
    String color = 'Mặc định',
  }) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.size == size &&
          item.color == color,
    );

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product, size: size, color: color));
    }
    notifyListeners();
    _persist();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
    _persist();
  }

  void updateQuantity(CartItem item, int delta) {
    final newQuantity = item.quantity + delta;
    if (newQuantity <= 0) {
      // Handled by UI to show confirmation dialog
      return;
    }
    item.quantity = newQuantity;
    notifyListeners();
    _persist();
  }

  void toggleSelection(CartItem item) {
    item.isSelected = !item.isSelected;
    notifyListeners();
    _persist();
  }

  void toggleSelectAll(bool selected) {
    for (var item in _items) {
      item.isSelected = selected;
    }
    notifyListeners();
    _persist();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _persist();
  }

  // Helper to add mock data for testing
  void addMockItems(List<ProductItem> products) {
    for (var i = 0; i < products.length && i < 3; i++) {
      _items.add(
        CartItem(
          product: products[i],
          quantity: i + 1,
          size: i == 0 ? 'S' : (i == 1 ? 'M' : 'L'),
          color: i == 0 ? 'Đỏ' : (i == 1 ? 'Xanh' : 'Đen'),
        ),
      );
    }
    notifyListeners();
    _persist();
  }
}

import 'package:flutter/material.dart';
import '../models/product_item.dart';
import '../models/cart_item.dart';
import '../services/storage_service.dart';

class UserController extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<CartItem> _cart = [];

  UserController() {
    _loadCartFromStorage();
  }

  List<CartItem> get cart => List.unmodifiable(_cart);

  int get totalItems => _cart.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _cart.fold(0.0, (sum, item) => sum + item.totalPrice);

  Future<void> _loadCartFromStorage() async {
    _cart = await _storageService.loadCart();
    notifyListeners();
  }

  Future<void> _saveCartToStorage() async {
    await _storageService.saveCart(_cart);
  }

  void addToCart(ProductItem product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _cart[index].quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    _saveCartToStorage();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    _saveCartToStorage();
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = newQuantity;
      }
      _saveCartToStorage();
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    _storageService.clearCart();
    notifyListeners();
  }
}

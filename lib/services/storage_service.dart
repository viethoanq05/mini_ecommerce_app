import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class StorageService {
  static const String _cartKey = 'user_cart';

  Future<void> saveCart(List<CartItem> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      cart.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_cartKey, encodedData);
  }

  Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString(_cartKey);

    if (cartData == null || cartData.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedData = json.decode(cartData);
      return decodedData.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistProvider extends ChangeNotifier {
  static const String _storageKey = 'wishlist_product_ids';

  final Set<String> _productIds = <String>{};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  int get count => _productIds.length;

  Set<String> get productIds => Set<String>.unmodifiable(_productIds);

  bool isFavorite(String productId) => _productIds.contains(productId);

  Future<void> load() async {
    if (_isLoaded) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _productIds
        ..clear()
        ..addAll(decoded.map((e) => e.toString()));
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(String productId) async {
    if (_productIds.contains(productId)) {
      _productIds.remove(productId);
    } else {
      _productIds.add(productId);
    }
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_productIds.toList()));
  }
}

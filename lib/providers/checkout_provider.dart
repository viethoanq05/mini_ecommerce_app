import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../services/order_service.dart';
import '../controllers/cart_provider.dart';

enum ShippingMethod { standard, express }

enum PaymentMethod { cod, online }

class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider({OrderService? orderService})
    : _orderService = orderService ?? OrderService() {
    _loadOrderHistory();
  }

  static const _orderHistoryKey = 'order_history';

  final OrderService _orderService;

  /// Cart items are synced from [CartProvider] via [updateFromCartProvider].
  List<CartItem> _cartItems = [];

  final List<Order> _orderHistory = [];
  List<Order> get orderHistory => List.unmodifiable(_orderHistory);

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  bool get isCartEmpty => _cartItems.isEmpty;

  Address? _selectedAddress;
  Address? get selectedAddress => _selectedAddress;

  ShippingMethod _shippingMethod = ShippingMethod.standard;
  ShippingMethod get shippingMethod => _shippingMethod;

  PaymentMethod? _paymentMethod;
  PaymentMethod? get paymentMethod => _paymentMethod;

  String? _voucherCode;
  String? get voucherCode => _voucherCode;

  double _discount = 0;
  double get discount => _discount;

  bool _isPlacingOrder = false;
  bool get isPlacingOrder => _isPlacingOrder;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Mock addresses; replace with real API data as needed.
  final List<Address> _availableAddresses = [
    Address(
      id: 'addr_1',
      name: 'Nguyen Van A',
      phone: '0912345678',
      addressLine: '123 Le Loi',
      city: 'Ho Chi Minh',
    ),
    Address(
      id: 'addr_2',
      name: 'Tran Thi B',
      phone: '0987654321',
      addressLine: '456 Nguyen Trai',
      city: 'Ha Noi',
    ),
  ];

  List<Address> get availableAddresses =>
      List.unmodifiable(_availableAddresses);

  void addNewAddress(Address address) {
    _availableAddresses.add(address);
    notifyListeners();
  }

  void updateFromCartProvider(CartProvider cartProvider) {
    // CartProvider already stores CartItem models for the checkout flow.
    _cartItems = cartProvider.items.toList();
    notifyListeners();
  }

  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void selectShippingMethod(ShippingMethod method) {
    _shippingMethod = method;
    notifyListeners();
  }

  void selectPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void updateVoucherCode(String code) {
    _voucherCode = code.trim();
    notifyListeners();
  }

  void applyVoucher() {
    final code = _voucherCode?.trim();
    if (code == null || code.isEmpty) {
      _discount = 0;
      notifyListeners();
      return;
    }

    // Simple voucher rules for demo.
    switch (code.toLowerCase()) {
      case 'save10':
        _discount = subtotal * 0.10;
        break;
      case 'free20':
        _discount = 20000;
        break;
      case 'big50':
        _discount = subtotal * 0.50;
        break;
      case 'freeship':
        _discount = shippingFee;
        break;
      default:
        _discount = 0;
        _errorMessage = 'Voucher không hợp lệ';
        notifyListeners();
        return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void clearVoucher() {
    _voucherCode = null;
    _discount = 0;
    _errorMessage = null;
    notifyListeners();
  }

  double get subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get shippingFee {
    switch (_shippingMethod) {
      case ShippingMethod.express:
        return 20000;
      case ShippingMethod.standard:
        return 15000;
    }
  }

  double get total {
    return (subtotal + shippingFee - discount).clamp(0, double.infinity);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<Order> placeOrder({
    required String userId,
    required CartProvider cartProvider,
  }) async {
    if (isCartEmpty) {
      throw Exception('Giỏ hàng trống');
    }

    if (_selectedAddress == null) {
      throw Exception('Vui lòng chọn địa chỉ giao hàng');
    }

    if (_paymentMethod == null) {
      throw Exception('Vui lòng chọn phương thức thanh toán');
    }

    _isPlacingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderService.createOrder(
        userId: userId,
        addressId: _selectedAddress!.id,
        paymentMethod: _paymentMethod!.name,
        shippingMethod: _shippingMethod.name,
        items: _cartItems
            .map(
              (item) => OrderItem(
                productId: item.product.id,
                quantity: item.quantity,
                price: item.product.price,
              ),
            )
            .toList(),
        subtotal: subtotal,
        shippingFee: shippingFee,
        discount: discount,
        total: total,
      );

      // Clear cart after successful order
      cartProvider.clearCart();

      // Save to local order history for demo.
      _orderHistory.insert(0, order);
      await _saveOrderHistory();

      return order;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  Future<void> _loadOrderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_orderHistoryKey);
      if (raw == null || raw.isEmpty) {
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return;
      }

      _orderHistory
        ..clear()
        ..addAll(
          decoded
              .whereType<Map<String, dynamic>>()
              .map(Order.fromJson)
              .toList(),
        );
      notifyListeners();
    } catch (_) {
      // Ignore errors (cache corruption etc.)
    }
  }

  Future<void> _saveOrderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_orderHistory.map((e) => e.toJson()).toList());
      await prefs.setString(_orderHistoryKey, encoded);
    } catch (_) {
      // Ignore errors.
    }
  }
}

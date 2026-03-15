import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/order.dart';
import '../models/order_item.dart';

/// A simple service that creates orders using a backend API.
///
/// Update [baseUrl] to point to a real backend. The current base URL is a
/// placeholder that will likely return an error unless replaced.
class OrderService {
  OrderService({
    this.baseUrl = 'https://example.com',
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  bool get _useMock => baseUrl.contains('example.com');

  Future<Order> createOrder({
    required String userId,
    required String addressId,
    required String paymentMethod,
    required String shippingMethod,
    required List<OrderItem> items,
    required double subtotal,
    required double shippingFee,
    required double discount,
    required double total,
  }) async {
    // When using the default placeholder URL, return a mock order so the flow works.
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return Order(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        addressId: addressId,
        paymentMethod: paymentMethod,
        shippingMethod: shippingMethod,
        items: items,
        subtotal: subtotal,
        shippingFee: shippingFee,
        discount: discount,
        total: total,
        createdAt: DateTime.now(),
        status: OrderStatus.pending,
      );
    }

    final uri = Uri.parse('$baseUrl/api/orders');

    final body = jsonEncode({
      'user_id': userId,
      'address_id': addressId,
      'payment_method': paymentMethod,
      'shipping_method': shippingMethod,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'discount': discount,
      'total': total,
    });

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Tạo đơn hàng không thành công (HTTP ${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Order.fromJson(decoded);
  }
}

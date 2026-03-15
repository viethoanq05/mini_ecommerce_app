import 'order_item.dart';

class Order {
  Order({
    required this.id,
    required this.userId,
    required this.addressId,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String addressId;
  final String paymentMethod;
  final String shippingMethod;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final DateTime createdAt;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      addressId: json['address_id']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      shippingMethod: json['shipping_method']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem(
                    productId: e['product_id']?.toString() ?? '',
                    quantity: (e['quantity'] as num?)?.toInt() ?? 0,
                    price: (e['price'] as num?)?.toDouble() ?? 0,
                  ))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

import 'order_item.dart';

enum OrderStatus { pending, delivering, delivered, canceled }

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
    required this.status,
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
  final OrderStatus status;

  factory Order.fromJson(Map<String, dynamic> json) {
    final statusRaw = json['status']?.toString();
    final status = OrderStatus.values.firstWhere(
      (s) => s.name == statusRaw,
      orElse: () => OrderStatus.pending,
    );

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
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'address_id': addressId,
      'payment_method': paymentMethod,
      'shipping_method': shippingMethod,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'discount': discount,
      'total': total,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
    };
  }
}

import 'package:flutter/material.dart';

import '../models/order.dart';
import '../utils/formatters.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mã đơn hàng: ${order.id}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text('Phương thức thanh toán: ${order.paymentMethod}'),
            const SizedBox(height: 4),
            Text('Phương thức vận chuyển: ${order.shippingMethod}'),
            const SizedBox(height: 16),
            const Text(
              'Sản phẩm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return ListTile(
                    title: Text('Sản phẩm: ${item.productId}'),
                    subtitle: Text('Số lượng: ${item.quantity}'),
                    trailing: Text(
                      formatCurrency(item.price * item.quantity, 'VND'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Tạm tính', value: order.subtotal),
            _InfoRow(label: 'Phí vận chuyển', value: order.shippingFee),
            _InfoRow(label: 'Giảm giá', value: -order.discount),
            const Divider(height: 24),
            _InfoRow(
              label: 'Tổng cộng',
              value: order.total,
              valueStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFFE03131),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final double value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6F6F6F)),
          ),
          Text(
            formatCurrency(value, 'VND'),
            style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

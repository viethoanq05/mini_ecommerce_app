import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
  });

  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tóm tắt đơn hàng',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Tạm tính', value: subtotal),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Phí vận chuyển', value: shippingFee),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Giảm giá', value: -discount),
          const Divider(height: 22, thickness: 1),
          _SummaryRow(
            label: 'Tổng cộng',
            value: total,
            valueStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFFE03131),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final double value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6F6F6F)),
        ),
        Text(
          formatCurrency(value, 'VND'),
          style: valueStyle ?? const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

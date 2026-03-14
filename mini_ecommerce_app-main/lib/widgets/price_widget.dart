import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class PriceWidget extends StatelessWidget {
  const PriceWidget({
    super.key,
    required this.price,
    required this.originalPrice,
    this.compact = false,
  });

  final double price;
  final double originalPrice;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatCurrency(price, 'VND'),
          style: TextStyle(
            color: Color(0xFFE53935),
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        SizedBox(height: compact ? 1 : 2),
        Text(
          formatCurrency(originalPrice, 'VND'),
          style: TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: compact ? 11 : 12,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }
}

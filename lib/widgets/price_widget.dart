import 'package:flutter/material.dart';

class PriceWidget extends StatelessWidget {
  final double price;
  final double originalPrice;

  const PriceWidget({
    super.key,
    required this.price,
    required this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatPrice(price),
          style: const TextStyle(
            color: Color(0xFFEE4D2D),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatPrice(originalPrice),
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
            decoration: TextDecoration.lineThrough,
            decorationColor: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  String _formatPrice(double value) {
    final source = value.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < source.length; i++) {
      if (i > 0 && (source.length - i) % 3 == 0) buffer.write('.');
      buffer.write(source[i]);
    }
    return '${buffer.toString()}đ';
  }
}

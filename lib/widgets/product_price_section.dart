import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/product.dart';

class ProductPriceSection extends StatelessWidget {
  final Product product;
  final bool isLoading;

  const ProductPriceSection({
    super.key,
    required this.product,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Container(width: 140, height: 12, color: Colors.white),
              const SizedBox(height: 12),
              Container(width: 120, height: 24, color: Colors.white),
              const SizedBox(height: 6),
              Container(width: 70, height: 12, color: Colors.white),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  Icons.star_rounded,
                  size: 17,
                  color: index < product.rating.floor()
                      ? const Color(0xFFFFC107)
                      : Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${product.rating.toStringAsFixed(1)})',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatPrice(product.price),
            style: const TextStyle(
              color: Color(0xFFEE4D2D),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatPrice(product.originalPrice),
            style: TextStyle(
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final value = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) buffer.write('.');
      buffer.write(value[i]);
    }
    return '$bufferđ';
  }
}

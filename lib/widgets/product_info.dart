import 'package:flutter/material.dart';
import '../models/product.dart';

/// Khối thông tin sản phẩm: giá bán (đỏ), giá gốc (gạch ngang), tên, rating.
class ProductInfo extends StatelessWidget {
  final Product product;

  const ProductInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng giá: giá bán + giá gốc + badge giảm giá
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatPrice(product.price),
                style: const TextStyle(
                  color: Color(0xFFEE4D2D),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatPrice(product.originalPrice),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 8),
              // Badge % giảm giá
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEE4D2D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFFEE4D2D),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '-${_discountPercent(product.price, product.originalPrice)}%',
                  style: const TextStyle(
                    color: Color(0xFFEE4D2D),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Tên sản phẩm
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 10),

          // Rating + đã bán
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: i < product.rating.floor()
                        ? const Color(0xFFFFD700)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                product.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Text('|', style: TextStyle(color: Colors.grey.shade400)),
              const SizedBox(width: 6),
              Text(
                'Đã bán ${product.reviews.length * 100}+',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    buf.write('đ');
    return buf.toString();
  }

  int _discountPercent(double price, double original) =>
      (((original - price) / original) * 100).round();
}

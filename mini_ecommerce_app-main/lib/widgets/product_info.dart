import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/formatters.dart';

/// Hiển thị tên sản phẩm, giá bán (màu đỏ), giá gốc (gạch ngang) và badge % giảm giá.
class ProductInfo extends StatelessWidget {
  const ProductInfo({
    super.key,
    required this.product,
    this.displayPrice,
    this.displayOriginalPrice,
  });

  final Product product;
  final double? displayPrice;
  final double? displayOriginalPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPrice = displayPrice ?? product.price;
    final currentOriginalPrice = displayOriginalPrice ?? product.originalPrice;
    final currentDiscount = currentOriginalPrice > currentPrice
        ? ((currentOriginalPrice - currentPrice) / currentOriginalPrice * 100)
            .round()
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hàng giá bán + giá gốc + badge giảm ──────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                formatCurrency(currentPrice, 'VND'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFFE03131),
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (currentOriginalPrice > currentPrice) ...[
                const SizedBox(width: 10),
                Text(
                  formatCurrency(currentOriginalPrice, 'VND'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 8),
                // Badge phần trăm giảm giá
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECEC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-$currentDiscount%',
                    style: const TextStyle(
                      color: Color(0xFFE03131),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // ── Tên sản phẩm ─────────────────────────────────────
          Text(
            product.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2B211D),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 8),

          // ── Đánh giá sao giả lập ─────────────────────────────
          Row(
            children: [
              ...List.generate(
                5,
                (i) => const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFFFFAB00),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${product.averageRating.toStringAsFixed(1)}  |  ${product.reviews.length} danh gia',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

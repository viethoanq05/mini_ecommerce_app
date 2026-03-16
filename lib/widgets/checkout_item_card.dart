import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../utils/formatters.dart';
import 'product_image.dart';

class CheckoutItemCard extends StatelessWidget {
  const CheckoutItemCard({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: ProductImage(
                imageUrl: item.product.imageUrl,
                heroTag: item.product.id,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Size: ${item.size} • Màu: ${item.color}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6F6F6F),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCurrency(item.product.price, item.product.currency),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFFE03131),
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6F6F6F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Subtotal: ${formatCurrency(item.totalPrice, item.product.currency)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

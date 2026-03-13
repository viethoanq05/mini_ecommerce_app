import 'package:flutter/material.dart';
import '../models/product.dart';

class RelatedProducts extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onSelect;

  const RelatedProducts({
    super.key,
    required this.products,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm liên quan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 212,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final item = products[index];
                return GestureDetector(
                  onTap: () => onSelect(item),
                  child: SizedBox(
                    width: 134,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.images.first,
                            width: 134,
                            height: 134,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 134,
                              height: 134,
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, height: 1.25),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPrice(item.price),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFEE4D2D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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

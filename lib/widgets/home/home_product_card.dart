import 'package:flutter/material.dart';

import '../../models/product_item.dart';
import '../../utils/formatters.dart';

class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    super.key,
    required this.product,
    required this.isCompact,
  });

  final ProductItem product;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = isCompact ? 18.0 : 24.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 9,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: product.id,
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) {
                            return child;
                          }

                          return AnimatedOpacity(
                            opacity: 0.65,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              color: const Color(0xFFF4E7DB),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.4),
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF4E7DB),
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported_outlined),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: isCompact ? 8 : 10,
                    top: isCompact ? 8 : 10,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: product.tags
                          .map(
                            (tag) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 6 : 8,
                                vertical: isCompact ? 4 : 5,
                              ),
                              decoration: BoxDecoration(
                                color: _tagColor(tag),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                tag,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 10 : 12,
                  isCompact ? 10 : 12,
                  isCompact ? 10 : 12,
                  isCompact ? 10 : 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: isCompact ? 13 : null,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: const Color(0xFF2B211D),
                      ),
                    ),
                    SizedBox(height: isCompact ? 8 : 10),
                    Text(
                      formatCurrency(product.price, product.currency),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: isCompact ? 15 : null,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE85D04),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_outlined,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Đã bán ${formatSold(product.soldCount)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF816C61),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _tagColor(String tag) {
    final normalized = tag.toLowerCase();
    if (normalized.contains('mall')) {
      return const Color(0xFFE85D04);
    }
    if (normalized.contains('yêu thích') || normalized.contains('favorite')) {
      return const Color(0xFFC92A2A);
    }
    return const Color(0xFF2B8A3E);
  }
}

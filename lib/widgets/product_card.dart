import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/product.dart';
import 'price_widget.dart';
import 'product_image.dart';
import 'sold_count.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;
  bool _hovered = false;
  bool _favorite = false;
  bool _imageReady = false;

  @override
  Widget build(BuildContext context) {
    final discountPercent = _discount(
      widget.product.price,
      widget.product.originalPrice,
    );
    final soldCount = (widget.product.reviews.length * 430) + 340;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _pressed
            ? 0.97
            : _hovered
            ? 1.02
            : 1,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFFFF4F1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered ? const Color(0xFFFFD5CB) : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.12 : 0.06),
                blurRadius: _hovered ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onHighlightChanged: (value) => setState(() => _pressed = value),
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImage(
                    imageUrl: widget.product.images.first,
                    heroTag: widget.product.id,
                    discountPercent: discountPercent,
                    isHovered: _hovered,
                    isFavorite: _favorite,
                    onFavoriteTap: () => setState(() => _favorite = !_favorite),
                    onLoaded: () {
                      if (!_imageReady && mounted) {
                        setState(() => _imageReady = true);
                      }
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _imageReady
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                PriceWidget(
                                  price: widget.product.price,
                                  originalPrice: widget.product.originalPrice,
                                ),
                                const Spacer(),
                                SoldCount(sold: soldCount),
                              ],
                            )
                          : _skeleton(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _skeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 12, width: double.infinity, color: Colors.white),
          const SizedBox(height: 6),
          Container(height: 12, width: 130, color: Colors.white),
          const SizedBox(height: 10),
          Container(height: 16, width: 90, color: Colors.white),
          const SizedBox(height: 6),
          Container(height: 12, width: 70, color: Colors.white),
        ],
      ),
    );
  }

  int _discount(double price, double originalPrice) {
    if (originalPrice <= 0) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }
}

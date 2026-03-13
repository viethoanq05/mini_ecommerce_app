import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductImage extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final int discountPercent;
  final bool isHovered;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onLoaded;

  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    required this.discountPercent,
    this.isHovered = false,
    required this.isFavorite,
    required this.onFavoriteTap,
    this.onLoaded,
  });

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  bool _notified = false;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: widget.heroTag,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 160),
              scale: widget.isHovered ? 1.04 : 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: widget.isHovered ? 0.06 : 0),
                    BlendMode.screen,
                  ),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) {
                        _notifyLoaded();
                        return child;
                      }
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(color: Colors.white),
                      );
                    },
                    errorBuilder: (_, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 140),
            opacity: widget.isHovered ? 1 : 0,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEE4D2D),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '-${widget.discountPercent}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.onFavoriteTap,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: widget.isFavorite
                        ? const Color(0xFFEE4D2D)
                        : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _notifyLoaded() {
    if (_notified) return;
    _notified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLoaded?.call();
    });
  }
}

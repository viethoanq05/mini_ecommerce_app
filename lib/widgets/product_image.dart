import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  final String imageUrl;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: Hero(
        tag: heroTag,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }
            return Shimmer.fromColors(
              baseColor: const Color(0xFFEDEDED),
              highlightColor: const Color(0xFFF8F8F8),
              child: Container(color: Colors.white),
            );
          },
          errorBuilder: (_, __, ___) {
            return Container(
              color: const Color(0xFFF4F4F4),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: Color(0xFF9E9E9E),
              ),
            );
          },
        ),
      ),
    );
  }
}

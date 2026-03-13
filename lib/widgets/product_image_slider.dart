import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

/// Slider ảnh sản phẩm — vuốt ngang xem nhiều ảnh, có dots indicator.
class ProductImageSlider extends StatefulWidget {
  final Product product;

  const ProductImageSlider({super.key, required this.product});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _currentIndex = 0;

  void _openImagePreview(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImagePreviewScreen(
          images: widget.product.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 320,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, _) =>
                  setState(() => _currentIndex = index),
            ),
            items: widget.product.images.asMap().entries.map((entry) {
              final child = Image.network(
                entry.value,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 320,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              );

              // Hero animation chỉ trên ảnh đầu tiên (khớp với ProductCard ở HomeScreen)
              final imageWidget = entry.key == 0
                  ? Hero(tag: widget.product.id, child: child)
                  : child;

              return GestureDetector(
                onTap: () => _openImagePreview(entry.key),
                child: imageWidget,
              );
            }).toList(),
          ),

          // Dots indicator phía dưới slider
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.product.images.asMap().entries.map((entry) {
                final isActive = _currentIndex == entry.key;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 16 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive
                        ? const Color(0xFFEE4D2D)
                        : Colors.white.withValues(alpha: 0.75),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreviewScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImagePreviewScreen({required this.images, required this.initialIndex});

  @override
  State<_ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<_ImagePreviewScreen> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1}/${widget.images.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (_, index) => Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Image.network(
              widget.images[index],
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

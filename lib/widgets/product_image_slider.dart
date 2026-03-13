import 'package:flutter/material.dart';

/// Slider ảnh sản phẩm với vuốt ngang và dots indicator.
/// Ảnh đầu tiên được bọc Hero để animate khi chuyển màn hình.
class ProductImageSlider extends StatefulWidget {
  const ProductImageSlider({
    super.key,
    required this.images,
    required this.heroTag,
    this.onPageChanged,
    this.activeImageUrl,
  });

  final List<String> images;

  /// Hero tag khớp với tag đã dùng ở HomeProductCard (product.id)
  final String heroTag;

  final ValueChanged<int>? onPageChanged;

  /// Khi màu đổi, parent truyền URL ảnh ưu tiên để slider nhảy về ảnh phù hợp.
  final String? activeImageUrl;

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant ProductImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeImageUrl == null || widget.activeImageUrl!.isEmpty) {
      return;
    }
    final targetIndex = widget.images.indexOf(widget.activeImageUrl!);
    if (targetIndex < 0 || targetIndex == _currentIndex) {
      return;
    }
    _currentIndex = targetIndex;
    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _openFullScreen(context, _currentIndex),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.images.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                      widget.onPageChanged?.call(index);
                    },
                    itemBuilder: (context, index) {
                      final networkImage = Image.network(
                        widget.images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFFF4E7DB),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF4E7DB),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );

                      return index == 0
                          ? Hero(tag: widget.heroTag, child: networkImage)
                          : networkImage;
                    },
                  ),
                ),
                if (widget.images.length > 1)
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.images.length, (i) {
                        final isActive = i == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.white60,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                Positioned(
                  bottom: 14,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.images.length > 1)
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isActive = index == _currentIndex;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 1.8,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.images[index],
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                        ),
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

  void _openFullScreen(BuildContext context, int initialPage) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (_) {
        final fullController = PageController(initialPage: initialPage);
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PageView.builder(
                controller: fullController,
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 12,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageSlider extends StatefulWidget {
  final String heroTag;
  final List<String> images;
  final ValueNotifier<int>? externalIndex;
  final ValueChanged<int>? onIndexChanged;

  const ImageSlider({
    super.key,
    required this.heroTag,
    required this.images,
    this.externalIndex,
    this.onIndexChanged,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();
  int _current = 0;
  late final ValueNotifier<int>? _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.externalIndex;
    _notifier?.addListener(_onExternalIndexChange);
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onExternalIndexChange);
    _pageController.dispose();
    super.dispose();
  }

  void _onExternalIndexChange() {
    final target = _notifier?.value ?? 0;
    if (target < 0 || target >= widget.images.length || target == _current) {
      return;
    }
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _current = index);
              widget.onIndexChanged?.call(index);
            },
            itemBuilder: (_, index) {
              final image = _ZoomableImage(imageUrl: widget.images[index]);
              final wrapped = index == 0
                  ? Hero(tag: widget.heroTag, child: image)
                  : image;
              return GestureDetector(
                onTap: () => _openFullscreen(index),
                child: wrapped,
              );
            },
          ),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                final active = index == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFFEE4D2D) : Colors.white70,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullscreen(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenGallery(
          images: widget.images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  final String imageUrl;

  const _ZoomableImage({required this.imageUrl});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 4,
        child: Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(color: Colors.white),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image_not_supported,
              size: 60,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
      return;
    }
    final tapPosition = _doubleTapDetails?.localPosition;
    if (tapPosition == null) return;

    final zoomed = Matrix4.identity()
      ..translate(-tapPosition.dx * 1.8, -tapPosition.dy * 1.8)
      ..scale(2.8);
    _controller.value = zoomed;
  }
}

class _FullscreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullscreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
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
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (_, index) => Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Image.network(widget.images[index], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/banner_item.dart';

class HomeBannerCarousel extends StatelessWidget {
  const HomeBannerCarousel({
    super.key,
    required this.controller,
    required this.banners,
    required this.currentIndex,
    required this.onPageChanged,
    required this.bannerHeight,
  });

  final PageController controller;
  final List<BannerItem> banners;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final double bannerHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final compact = availableWidth < 360;
        final wide = availableWidth >= 700;
        final indicatorHeight = compact ? 6.0 : 8.0;
        final indicatorActiveWidth = compact ? 18.0 : 22.0;
        final indicatorInactiveWidth = compact ? 7.0 : 8.0;

        return Column(
          children: [
            SizedBox(
              height: bannerHeight,
              child: PageView.builder(
                controller: controller,
                onPageChanged: onPageChanged,
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  final radius = (bannerHeight * 0.16).clamp(18.0, 34.0);
                  final imageWidth = (availableWidth * (wide ? 0.34 : 0.4))
                      .clamp(110.0, 230.0);
                  final imageHeight = (bannerHeight * 0.88).clamp(120.0, 210.0);
                  final contentPadding = (bannerHeight * (compact ? 0.1 : 0.12))
                      .clamp(14.0, 28.0);
                  final tagHorizontal = compact ? 8.0 : 10.0;
                  final tagVertical = compact ? 4.0 : 6.0;

                  return Padding(
                    padding: EdgeInsets.only(right: compact ? 8 : 10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        gradient: LinearGradient(
                          colors: banner.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: banner.gradient.last.withValues(alpha: 0.28),
                            blurRadius: wide ? 28 : 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -8,
                            bottom: -10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(radius),
                              child: Image.network(
                                banner.imageUrl,
                                width: imageWidth,
                                height: imageHeight,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: imageWidth,
                                    height: imageHeight,
                                    color: Colors.black.withValues(alpha: 0.08),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.all(contentPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: tagHorizontal,
                                      vertical: tagVertical,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      banner.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width:
                                        availableWidth * (compact ? 0.52 : 0.6),
                                    child: Text(
                                      banner.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontSize: compact
                                                ? 16
                                                : wide
                                                ? 24
                                                : 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            height: 1.15,
                                          ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 4 : 8),
                                  SizedBox(
                                    width:
                                        availableWidth *
                                        (compact ? 0.56 : 0.62),
                                    child: Text(
                                      banner.subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontSize: compact ? 11 : null,
                                            color: Colors.white.withValues(
                                              alpha: 0.92,
                                            ),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (index) {
                final isActive = index == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: isActive
                      ? indicatorActiveWidth
                      : indicatorInactiveWidth,
                  height: indicatorHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/category_item.dart';

class HomeCategoryCard extends StatelessWidget {
  const HomeCategoryCard({super.key, required this.category});

  final CategoryItem category;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        final iconBox = size * 0.42;
        final iconSize = size * 0.25;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: category.color.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: category.color.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: iconSize,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: const Color(0xFF2E2521),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

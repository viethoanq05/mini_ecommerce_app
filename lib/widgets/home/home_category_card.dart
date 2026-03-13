import 'package:flutter/material.dart';

import '../../models/category_item.dart';

class HomeCategoryCard extends StatelessWidget {
  const HomeCategoryCard({super.key, required this.category});

  final CategoryItem category;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortest = constraints.biggest.shortestSide;
        final isTight = constraints.maxHeight < 110;
        final iconBox = (shortest * (isTight ? 0.30 : 0.36)).clamp(26.0, 40.0);
        final iconSize = (iconBox * 0.58).clamp(15.0, 23.0);
        final verticalPadding = isTight ? 4.0 : 8.0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: verticalPadding,
          ),
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
              SizedBox(height: isTight ? 4 : 6),
              Expanded(
                child: Center(
                  child: Text(
                    category.title,
                    maxLines: isTight ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: isTight ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: const Color(0xFF2E2521),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

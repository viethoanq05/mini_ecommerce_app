import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.isCollapsed,
    required this.height,
  });

  final bool isCollapsed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: height,
      decoration: BoxDecoration(
        color: isCollapsed
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: isCollapsed
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isCollapsed
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Row(
        children: [
          SizedBox(width: height * 0.3),
          Icon(
            Icons.search_rounded,
            size: height * 0.5,
            color: isCollapsed
                ? Colors.white.withValues(alpha: 0.92)
                : const Color(0xFF7A5C4D),
          ),
          SizedBox(width: height * 0.22),
          Expanded(
            child: Text(
              'Tìm đồ hot, deal sốc, voucher...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isCollapsed
                    ? Colors.white.withValues(alpha: 0.96)
                    : const Color(0xFF6B5B53),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 1,
            height: height * 0.4,
            color: isCollapsed
                ? Colors.white.withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: 0.08),
          ),
          IconButton(
            onPressed: () {},
            splashRadius: 20,
            icon: Icon(
              Icons.tune_rounded,
              size: height * 0.46,
              color: isCollapsed
                  ? Colors.white.withValues(alpha: 0.92)
                  : const Color(0xFF7A5C4D),
            ),
          ),
        ],
      ),
    );
  }
}

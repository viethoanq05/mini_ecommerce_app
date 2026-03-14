import 'package:flutter/material.dart';

/// Khối mô tả sản phẩm với tính năng "Xem thêm" / "Thu gọn".
/// Ban đầu hiện tối đa [maxLines] dòng, bấm để mở full.
class ProductDescription extends StatefulWidget {
  const ProductDescription({
    super.key,
    required this.description,
    this.maxLines = 5,
  });

  final String description;
  final int maxLines;

  @override
  State<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tiêu đề ──────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Mô tả sản phẩm',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Nội dung mô tả với AnimatedCrossFade ─────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              widget.description,
              maxLines: widget.maxLines,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF555555),
                height: 1.65,
              ),
            ),
            secondChild: Text(
              widget.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF555555),
                height: 1.65,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Nút Xem thêm / Thu gọn ───────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _expanded ? 'Thu gọn' : 'Xem thêm',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

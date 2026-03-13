import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int collapsedLines;

  const ExpandableText({
    super.key,
    required this.text,
    this.collapsedLines = 5,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            widget.text,
            maxLines: widget.collapsedLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(height: 1.6, fontSize: 14),
          ),
          secondChild: Text(
            widget.text,
            style: const TextStyle(height: 1.6, fontSize: 14),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _expanded ? 'Thu gọn' : 'Xem thêm',
                style: const TextStyle(
                  color: Color(0xFFEE4D2D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                _expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFFEE4D2D),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

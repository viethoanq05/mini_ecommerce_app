import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class SoldCount extends StatelessWidget {
  const SoldCount({
    super.key,
    required this.count,
    this.compact = false,
  });

  final int count;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Da ban ${formatSold(count)}',
      style: TextStyle(
        color: Color(0xFF8D8D8D),
        fontSize: compact ? 11 : 12,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

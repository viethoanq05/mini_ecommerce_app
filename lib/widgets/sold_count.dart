import 'package:flutter/material.dart';

class SoldCount extends StatelessWidget {
  final int sold;

  const SoldCount({super.key, required this.sold});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Đã bán ${_formatSoldCount(sold)}',
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _formatSoldCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}m';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }
}

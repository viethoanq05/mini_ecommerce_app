import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}

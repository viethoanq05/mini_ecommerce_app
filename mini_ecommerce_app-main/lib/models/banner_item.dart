import 'package:flutter/material.dart';

class BannerItem {
  const BannerItem({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.gradient,
  });

  final String label;
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Color> gradient;
}

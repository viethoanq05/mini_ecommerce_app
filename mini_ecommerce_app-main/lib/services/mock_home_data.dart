import 'package:flutter/material.dart';

import '../models/banner_item.dart';
import '../models/category_item.dart';
import '../models/product_item.dart';

const int defaultPageSize = 8;

List<BannerItem> buildMockBanners() {
  return const [
    BannerItem(
      label: 'FLASH SALE',
      title: 'Giảm đến 50% cho đồ gia dụng',
      subtitle: 'Mã freeship và voucher áp dụng đến hết hôm nay.',
      imageUrl: 'https://picsum.photos/seed/banner-home/600/800',
      gradient: [Color(0xFFF48C06), Color(0xFFE85D04)],
    ),
    BannerItem(
      label: 'MALL WEEK',
      title: 'Mỹ phẩm chính hãng giá mềm',
      subtitle: 'Combo serum, son và chăm sóc da cho mùa mới.',
      imageUrl: 'https://picsum.photos/seed/banner-beauty/600/800',
      gradient: [Color(0xFFE76F51), Color(0xFFD62828)],
    ),
    BannerItem(
      label: 'TECH DEAL',
      title: 'Điện thoại, tai nghe và phụ kiện hot',
      subtitle: 'Giá tốt mỗi 4 giờ, số lượng có hạn.',
      imageUrl: 'https://picsum.photos/seed/banner-tech/600/800',
      gradient: [Color(0xFF277DA1), Color(0xFF1D3557)],
    ),
    BannerItem(
      label: 'FASHION DAY',
      title: 'Thời trang mới lên kệ, săn deal ngay',
      subtitle: 'Outfit đi học, đi làm và dạo phố đều có.',
      imageUrl: 'https://picsum.photos/seed/banner-fashion/600/800',
      gradient: [Color(0xFF8338EC), Color(0xFF3A0CA3)],
    ),
  ];
}

List<CategoryItem> buildMockCategories() {
  return const [
    CategoryItem(
      title: 'Thời trang',
      icon: Icons.checkroom_rounded,
      color: Color(0xFFE76F51),
    ),
    CategoryItem(
      title: 'Điện thoại',
      icon: Icons.smartphone_rounded,
      color: Color(0xFF277DA1),
    ),
    CategoryItem(
      title: 'Mỹ phẩm',
      icon: Icons.spa_rounded,
      color: Color(0xFFC1121F),
    ),
    CategoryItem(
      title: 'Đồ gia dụng',
      icon: Icons.kitchen_rounded,
      color: Color(0xFFF48C06),
    ),
    CategoryItem(
      title: 'Sách hay',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF6A994E),
    ),
    CategoryItem(
      title: 'Thể thao',
      icon: Icons.sports_basketball_rounded,
      color: Color(0xFF9C6644),
    ),
    CategoryItem(
      title: 'Mẹ & Bé',
      icon: Icons.child_care_rounded,
      color: Color(0xFFB5179E),
    ),
    CategoryItem(
      title: 'Laptop',
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFF4361EE),
    ),
  ];
}

List<ProductItem> generateMockProducts({
  required int page,
  int pageSize = defaultPageSize,
}) {
  const productNames = [
    'Áo khoác bomber unisex form rộng chống nắng nhẹ',
    'Tai nghe Bluetooth chống ồn pin trâu cho sinh viên',
    'Son lì dưỡng môi màu cam đất bán chạy',
    'Nồi chiên không dầu dung tích lớn 6L',
    'Balo laptop chống nước nhiều ngăn tiện dụng',
    'Đèn ngủ cảm ứng ánh sáng vàng êm mắt',
    'Giày thể thao đế êm phối màu trẻ trung',
    'Serum cấp ẩm phục hồi da dùng hằng ngày',
  ];

  const tagSets = [
    ['Mall', 'Giảm 50%'],
    ['Yêu thích'],
    ['Mall'],
    ['Giảm 50%'],
    ['Yêu thích', 'Mall'],
    ['Giảm 50%'],
    ['Yêu thích'],
    ['Mall', 'Yêu thích'],
  ];

  return List<ProductItem>.generate(pageSize, (index) {
    final seed = page * pageSize + index;
    final baseName = productNames[index % productNames.length];
    final isUsd = seed % 5 == 0;

    return ProductItem(
      id: 'product-$seed',
      name: '$baseName ${seed + 1}',
      imageUrl: 'https://picsum.photos/seed/product-$seed/700/900',
      price: isUsd ? 15 + seed * 1.35 : 125000 + seed * 17500,
      currency: isUsd ? 'USD' : 'VND',
      soldCount: 180 + seed * 137,
      tags: tagSets[index % tagSets.length],
    );
  });
}

import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../models/product_item.dart';
import '../../screens/product_detail_screen.dart';
import '../../utils/formatters.dart';

class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    super.key,
    required this.product,
    required this.isCompact,
  });

  final ProductItem product;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = isCompact ? 18.0 : 24.0;

    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 9,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: product.id,
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }

                            return AnimatedOpacity(
                              opacity: 0.65,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                color: const Color(0xFFF4E7DB),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF4E7DB),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      left: isCompact ? 8 : 10,
                      top: isCompact ? 8 : 10,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: product.tags
                            .map(
                              (tag) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 6 : 8,
                                  vertical: isCompact ? 4 : 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _tagColor(tag),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  tag,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 8,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 10 : 12,
                    isCompact ? 10 : 12,
                    isCompact ? 10 : 12,
                    isCompact ? 10 : 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: isCompact ? 13 : null,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: const Color(0xFF2B211D),
                        ),
                      ),
                      SizedBox(height: isCompact ? 8 : 10),
                      Text(
                        formatCurrency(product.price, product.currency),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: isCompact ? 15 : null,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFE85D04),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_outlined,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Đã bán ${formatSold(product.soldCount)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF816C61),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Chuyển sang màn hình chi tiết sản phẩm với Hero animation
  void _navigateToDetail(BuildContext context) {
    // Tạo Product đầy đủ từ ProductItem với dữ liệu demo
    final fullProduct = Product(
      id: product.id,
      name: product.name,
      price: product.price,
      originalPrice: product.price * 1.35,
      description:
          'Sản phẩm chất lượng cao với thiết kế hiện đại, phù hợp với nhiều phong cách khác nhau. '
          'Chất liệu cao cấp, bền đẹp và thoải mái khi sử dụng hàng ngày.\n\n'
          'Đặc điểm nổi bật:\n'
          '• Chất liệu: cao cấp 100%, thoáng mát, thấm hút tốt\n'
          '• Thiết kế: trẻ trung, năng động, dễ phối đồ\n'
          '• Phù hợp cho đi học, đi làm, đi chơi\n'
          '• Xuất xứ: Việt Nam – đạt chuẩn kiểm định chất lượng\n\n'
          'Hướng dẫn bảo quản:\n'
          '• Giặt máy ở nhiệt độ bình thường\n'
          '• Không dùng chất tẩy mạnh\n'
          '• Phơi trong bóng mát để giữ màu bền lâu\n\n'
          'Chính sách đổi trả trong 30 ngày nếu có lỗi từ nhà sản xuất.',
      images: [
        product.imageUrl,
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1200',
        'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=1200',
      ],
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
      colors: ['Đỏ', 'Xanh Navy', 'Đen', 'Trắng'],
      variants: [
        ProductVariant(size: 'S', color: 'Đỏ', stock: 3, price: product.price),
        ProductVariant(size: 'S', color: 'Đen', stock: 2, price: product.price),
        ProductVariant(
          size: 'S',
          color: 'Trắng',
          stock: 2,
          price: product.price + 3000,
        ),
        ProductVariant(size: 'M', color: 'Đỏ', stock: 1, price: product.price),
        ProductVariant(
          size: 'M',
          color: 'Xanh Navy',
          stock: 7,
          price: product.price + 7000,
        ),
        ProductVariant(
          size: 'M',
          color: 'Đen',
          stock: 5,
          price: product.price + 5000,
        ),
        ProductVariant(size: 'L', color: 'Đỏ', stock: 3, price: product.price),
        ProductVariant(
          size: 'L',
          color: 'Xanh Navy',
          stock: 6,
          price: product.price + 10000,
        ),
        ProductVariant(
          size: 'L',
          color: 'Đen',
          stock: 4,
          price: product.price + 9000,
        ),
        ProductVariant(
          size: 'XL',
          color: 'Đen',
          stock: 2,
          price: product.price + 13000,
        ),
        ProductVariant(
          size: 'XL',
          color: 'Trắng',
          stock: 1,
          price: product.price + 12000,
        ),
        ProductVariant(
          size: 'XXL',
          color: 'Đen',
          stock: 0,
          price: product.price + 18000,
        ),
      ],
      colorImages: {
        'Đỏ': [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1200',
          'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=1200',
        ],
        'Xanh Navy': [
          'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=1200',
          'https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=1200',
        ],
        'Đen': [
          'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?w=1200',
          'https://images.unsplash.com/photo-1528701800489-20be9c5f88df?w=1200',
        ],
        'Trắng': [
          'https://images.unsplash.com/photo-1605348532760-6753d2c43329?w=1200',
          'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=1200',
        ],
      },
      reviews: [
        ProductReview(
          id: 'rv-1',
          userName: 'Minh Anh',
          rating: 5,
          comment: 'Form đẹp, mang êm chân, đi cả ngày không đau.',
          imageUrl:
              'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=800',
          createdAt: DateTime(2026, 3, 1),
        ),
        ProductReview(
          id: 'rv-2',
          userName: 'Tuấn K',
          rating: 4,
          comment: 'Màu giống hình, giao nhanh. Nên tăng thêm size 42.',
          createdAt: DateTime(2026, 2, 25),
        ),
        ProductReview(
          id: 'rv-3',
          userName: 'Hà Vy',
          rating: 5,
          comment: 'Đóng gói kỹ, shop tư vấn nhiệt tình.',
          imageUrl:
              'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?w=800',
          createdAt: DateTime(2026, 2, 20),
        ),
      ],
      vouchers: const [
        ProductVoucher(
          id: 'vc-1',
          title: 'Giảm 20.000đ',
          discountAmount: 20000,
          minOrderValue: 120000,
        ),
        ProductVoucher(
          id: 'vc-2',
          title: 'Freeship 15.000đ',
          discountAmount: 15000,
          minOrderValue: 99000,
          isFreeship: true,
        ),
      ],
      relatedProducts: [
        RelatedProduct(
          id: '${product.id}-r1',
          name: 'Giày thể thao cổ thấp basic',
          imageUrl:
              'https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=700',
          price: product.price * 0.92,
        ),
        RelatedProduct(
          id: '${product.id}-r2',
          name: 'Giày chạy bộ phản quang',
          imageUrl:
              'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=700',
          price: product.price * 1.08,
        ),
      ],
    );

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: fullProduct),
      ),
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Mall':
        return const Color(0xFFE85D04);
      case 'Yêu thích':
        return const Color(0xFFC92A2A);
      default:
        return const Color(0xFF2B8A3E);
    }
  }
}

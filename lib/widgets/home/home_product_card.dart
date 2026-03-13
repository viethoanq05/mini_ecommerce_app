import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../models/product_item.dart';
import '../../controllers/currency_controller.dart';
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
    
    // Use CurrencyController to format price
    final currencyController = context.watch<CurrencyController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
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
                        fit: BoxFit.contain, // Changed to contain for products with background
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFFF4E7DB),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: Padding(
                padding: EdgeInsets.all(isCompact ? 10 : 12),
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
                        color: const Color(0xFF2B211D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyController.formatPrice(product.price),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: isCompact ? 15 : null,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE85D04),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '${product.soldCount} đã bán',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
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
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models/product.dart';
import '../models/product_item.dart';
import '../screens/product_detail_screen.dart';
import 'price_widget.dart';
import 'product_image.dart';
import 'sold_count.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
  });

  final ProductItem product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;
  bool _isPressed = false;
  bool _isHovered = false;

  ProductItem get _product => widget.product;

  double get _originalPrice => _product.price * 2;

  int get _discountPercent {
    final percent =
        ((_originalPrice - _product.price) / _originalPrice * 100).round();
    return percent.clamp(1, 90);
  }

  @override
  Widget build(BuildContext context) {
    final hoverColor = const Color(0xFFFFF6ED);

    return AnimatedScale(
      scale: _isPressed
          ? 0.98
          : _isHovered
              ? 1.01
              : 1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _isHovered ? hoverColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFFFFCBA3)
                  : const Color(0xFFF1F1F1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.1 : 0.06),
                blurRadius: _isHovered ? 16 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _openDetail(context),
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              hoverColor: Colors.transparent,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxHeight = constraints.maxHeight;
                  final desiredImageHeight = constraints.maxWidth / 1.1;
                  final imageHeight = desiredImageHeight.clamp(
                    92.0,
                    maxHeight * 0.54,
                  );
                  final compact = maxHeight < 250;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: imageHeight,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ProductImage(
                                  imageUrl: _product.imageUrl,
                                  heroTag: _product.id,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '-$_discountPercent%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Material(
                                  color: Colors.white,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      setState(
                                          () => _isFavorite = !_isFavorite);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        _isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 16,
                                        color: _isFavorite
                                            ? const Color(0xFFE53935)
                                            : const Color(0xFF6F6F6F),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _product.name,
                                maxLines: compact ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: compact ? 13 : 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: compact ? 4 : 6),
                              PriceWidget(
                                price: _product.price,
                                originalPrice: _originalPrice,
                                compact: compact,
                              ),
                              const Spacer(),
                              SoldCount(
                                count: _product.soldCount,
                                compact: compact,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    final fullProduct = Product(
      id: _product.id,
      name: _product.name,
      price: _product.price,
      originalPrice: _originalPrice,
      description:
          'San pham chat luong cao voi thiet ke hien dai, phu hop nhieu phong cach. '
          'Chat lieu ben dep va thoai mai khi su dung hang ngay.\n\n'
          'Dac diem noi bat:\n'
          '• Chat lieu cao cap, mem nhe\n'
          '• De phoi do, phu hop di hoc di lam\n'
          '• Chinh sach doi tra 30 ngay neu co loi nha san xuat.',
      images: [
        _product.imageUrl,
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1200',
        'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=1200',
      ],
      sizes: const ['S', 'M', 'L', 'XL'],
      colors: const ['Do', 'Xanh Navy', 'Den', 'Trang'],
      variants: [
        ProductVariant(size: 'S', color: 'Do', stock: 3, price: _product.price),
        ProductVariant(
          size: 'S',
          color: 'Den',
          stock: 0,
          price: _product.price,
        ),
        ProductVariant(
          size: 'M',
          color: 'Do',
          stock: 2,
          price: _product.price + 10000,
        ),
        ProductVariant(
          size: 'M',
          color: 'Xanh Navy',
          stock: 7,
          price: _product.price + 12000,
        ),
        ProductVariant(
          size: 'M',
          color: 'Den',
          stock: 5,
          price: _product.price + 8000,
        ),
        ProductVariant(
          size: 'L',
          color: 'Xanh Navy',
          stock: 6,
          price: _product.price + 15000,
        ),
        ProductVariant(
          size: 'L',
          color: 'Den',
          stock: 4,
          price: _product.price + 13000,
        ),
        ProductVariant(
          size: 'XL',
          color: 'Den',
          stock: 2,
          price: _product.price + 20000,
        ),
      ],
      colorImages: {
        'Do': [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1200',
          'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=1200',
        ],
        'Xanh Navy': [
          'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=1200',
          'https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=1200',
        ],
        'Den': [
          'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?w=1200',
          'https://images.unsplash.com/photo-1528701800489-20be9c5f88df?w=1200',
        ],
        'Trang': [
          'https://images.unsplash.com/photo-1605348532760-6753d2c43329?w=1200',
        ],
      },
      reviews: [
        ProductReview(
          id: 'rv-1',
          userName: 'Minh Anh',
          rating: 5,
          comment: 'Form dep, mang em chan.',
          imageUrl:
              'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=800',
          createdAt: DateTime(2026, 3, 1),
        ),
        ProductReview(
          id: 'rv-2',
          userName: 'Tuan K',
          rating: 4,
          comment: 'Mau giong hinh, giao nhanh.',
          createdAt: DateTime(2026, 2, 25),
        ),
      ],
      vouchers: const [
        ProductVoucher(
          id: 'vc-1',
          title: 'Giam 20.000d',
          discountAmount: 20000,
          minOrderValue: 120000,
        ),
        ProductVoucher(
          id: 'vc-2',
          title: 'Freeship 15.000d',
          discountAmount: 15000,
          minOrderValue: 99000,
          isFreeship: true,
        ),
      ],
      relatedProducts: [
        RelatedProduct(
          id: '${_product.id}-r1',
          name: 'Giay the thao co thap basic',
          imageUrl:
              'https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=700',
          price: _product.price * 0.92,
        ),
        RelatedProduct(
          id: '${_product.id}-r2',
          name: 'Giay chay bo phan quang',
          imageUrl:
              'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=700',
          price: _product.price * 1.08,
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

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9E9E9),
      highlightColor: const Color(0xFFF7F7F7),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight;
            final desiredImageHeight = constraints.maxWidth / 1.1;
            final imageHeight = desiredImageHeight.clamp(
              92.0,
              maxHeight * 0.58,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: imageHeight,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Container(height: 12, width: 96, color: Colors.white),
                        const Spacer(),
                        Container(height: 14, width: 72, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

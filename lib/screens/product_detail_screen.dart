import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/formatters.dart';
import '../widgets/product_description.dart';
import '../widgets/product_image_slider.dart';
import '../widgets/product_info.dart';
import '../widgets/variation_bottom_sheet.dart';

enum _ReviewSortMode { newest, highest, lowest }

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColor;
  ProductVoucher? _selectedVoucher;
  int? _selectedRating;
  bool _onlyWithImage = false;
  _ReviewSortMode _reviewSortMode = _ReviewSortMode.newest;

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();
    if (product.variants.isNotEmpty) {
      final available = product.variants.firstWhere(
        (item) => item.stock > 0,
        orElse: () => product.variants.first,
      );
      _selectedSize = available.size;
      _selectedColor = available.color;
    }
  }

  double get _selectedPrice {
    if (_selectedSize == null || _selectedColor == null) {
      return product.price;
    }
    return product.priceOf(_selectedSize!, _selectedColor!);
  }

  double get _selectedOriginalPrice {
    if (product.price <= 0) {
      return product.originalPrice;
    }
    final ratio = product.originalPrice / product.price;
    return _selectedPrice * ratio;
  }

  int get _selectedStock {
    if (_selectedSize == null || _selectedColor == null) {
      return product.totalStock;
    }
    return product.stockOf(_selectedSize!, _selectedColor!);
  }

  String? get _activeColorImage {
    final color = _selectedColor;
    if (color == null) {
      return null;
    }
    final colorImgs = product.colorImages[color];
    if (colorImgs == null || colorImgs.isEmpty) {
      return null;
    }
    return colorImgs.first;
  }

  List<ProductReview> get _filteredReviews {
    final list = product.reviews.where((item) {
      if (_selectedRating != null && item.rating != _selectedRating) {
        return false;
      }
      if (_onlyWithImage && !item.hasImage) {
        return false;
      }
      return true;
    }).toList();

    switch (_reviewSortMode) {
      case _ReviewSortMode.highest:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _ReviewSortMode.lowest:
        list.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case _ReviewSortMode.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return list;
  }

  Future<void> _toggleWishlist(BuildContext context) async {
    final provider = context.read<WishlistProvider>();
    await provider.toggleFavorite(product.id);
    if (!context.mounted) {
      return;
    }
    final isFavorite = provider.isFavorite(product.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'Da them vao danh sach yeu thich'
              : 'Da bo khoi danh sach yeu thich',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _shareDeepLink(BuildContext context) async {
    final deepLink = 'mini-ecommerce://product/${product.id}';
    await Clipboard.setData(ClipboardData(text: deepLink));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Da copy deep link san pham vao clipboard')),
    );
  }

  void _showVariationSheet(
    BuildContext context, {
    required String confirmLabel,
  }) {
    final cartProvider = context.read<CartProvider>();
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VariationBottomSheet(
        product: product,
        confirmLabel: confirmLabel,
        initialVoucher: _selectedVoucher,
        initialSize: _selectedSize,
        initialColor: _selectedColor,
        onConfirm: (size, color, quantity, voucher) {
          Navigator.pop(context);

          cartProvider.addToCart(
            product,
            size: size,
            color: color,
            quantity: quantity,
          );

          setState(() {
            _selectedSize = size;
            _selectedColor = color;
            _selectedVoucher = voucher;
          });

          messenger.showSnackBar(
            SnackBar(
              content: Text(
                confirmLabel == 'Mua ngay'
                    ? 'Dat hang thanh cong'
                    : 'Them vao gio hang thanh cong',
              ),
              backgroundColor: const Color(0xFF2B8A3E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().cartCount;
    final wishlist = context.watch<WishlistProvider>();
    final isFavorite = wishlist.isFavorite(product.id);
    final isOutOfStock = _selectedStock <= 0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
    final bottomBarReservedSpace =
        (screenWidth < 390 ? 130.0 : 110.0) + bottomSafeArea;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        actions: [
          Badge.count(
            count: wishlist.count,
            isLabelVisible: wishlist.count > 0,
            backgroundColor: const Color(0xFFE03131),
            child: _CircleIconButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              onTap: () => _toggleWishlist(context),
            ),
          ),
          _AnimatedCartBadge(
            count: cartCount,
            child: _AnimatedCircleCartButton(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gio hang cua ban dang duoc cap nhat'),
                    duration: Duration(milliseconds: 900),
                  ),
                );
              },
            ),
          ),
          _CircleIconButton(
            icon: Icons.share_outlined,
            onTap: () => _shareDeepLink(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageSlider(
              images: product.images,
              heroTag: product.id,
              activeImageUrl: _activeColorImage,
            ),
            ProductInfo(
              product: product,
              displayPrice: _selectedPrice,
              displayOriginalPrice: _selectedOriginalPrice,
            ),
            const SizedBox(height: 14),
            _VariationRow(
              product: product,
              selectedSize: _selectedSize,
              selectedColor: _selectedColor,
              selectedStock: _selectedStock,
              selectedPrice: _selectedPrice,
              onTap: () => _showVariationSheet(
                context,
                confirmLabel: 'Them vao gio hang',
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _VoucherSection(
              product: product,
              selectedVoucher: _selectedVoucher,
              onSelectVoucher: (voucher) {
                setState(() {
                  _selectedVoucher = voucher;
                });
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 8),
            const _ShippingInfo(),
            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 14),
            ProductDescription(description: product.description),
            const SizedBox(height: 16),
            _ReviewSection(
              product: product,
              selectedRating: _selectedRating,
              onlyWithImage: _onlyWithImage,
              sortMode: _reviewSortMode,
              filteredReviews: _filteredReviews,
              onRatingFilterChanged: (value) {
                setState(() {
                  _selectedRating = value;
                });
              },
              onSortChanged: (value) {
                setState(() {
                  _reviewSortMode = value;
                });
              },
              onToggleOnlyWithImage: () {
                setState(() {
                  _onlyWithImage = !_onlyWithImage;
                });
              },
            ),
            const SizedBox(height: 16),
            const _ShopPolicySection(),
            const SizedBox(height: 16),
            _RelatedProductsSection(related: product.relatedProducts),
            SizedBox(height: bottomBarReservedSpace),
          ],
        ),
      ),
      bottomNavigationBar: _BottomActionBar(
        cartCount: cartCount,
        isOutOfStock: isOutOfStock,
        onAddToCart: () =>
            _showVariationSheet(context, confirmLabel: 'Them vao gio hang'),
        onBuyNow: () => _showVariationSheet(context, confirmLabel: 'Mua ngay'),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(7),
      decoration: const BoxDecoration(
        color: Colors.black38,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 18),
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}

class _VariationRow extends StatelessWidget {
  const _VariationRow({
    required this.product,
    required this.onTap,
    required this.selectedSize,
    required this.selectedColor,
    required this.selectedStock,
    required this.selectedPrice,
  });

  final Product product;
  final VoidCallback onTap;
  final String? selectedSize;
  final String? selectedColor;
  final int selectedStock;
  final double selectedPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.style_outlined, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phan loai hang',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Da chon: ${selectedSize ?? '--'} / ${selectedColor ?? '--'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      Text(
                        formatCurrency(selectedPrice, 'VND'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFE03131),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        selectedStock > 0
                            ? 'Con $selectedStock sp'
                            : 'Het hang',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: selectedStock > 0
                              ? const Color(0xFF2B8A3E)
                              : const Color(0xFFC92A2A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _VoucherSection extends StatelessWidget {
  const _VoucherSection({
    required this.product,
    required this.selectedVoucher,
    required this.onSelectVoucher,
  });

  final Product product;
  final ProductVoucher? selectedVoucher;
  final ValueChanged<ProductVoucher?> onSelectVoucher;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.confirmation_number_outlined,
                  size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 10),
              Text(
                'Voucher cua shop',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.vouchers.map((voucher) {
              final selected = selectedVoucher?.id == voucher.id;
              return ChoiceChip(
                label: Text(voucher.title),
                selected: selected,
                onSelected: (_) => onSelectVoucher(selected ? null : voucher),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Freeship: co ap dung theo voucher du dieu kien',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShippingInfo extends StatelessWidget {
  const _ShippingInfo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Van chuyen',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Mien phi van chuyen · Giao du kien 2-4 ngay',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.product,
    required this.selectedRating,
    required this.onlyWithImage,
    required this.sortMode,
    required this.filteredReviews,
    required this.onRatingFilterChanged,
    required this.onSortChanged,
    required this.onToggleOnlyWithImage,
  });

  final Product product;
  final int? selectedRating;
  final bool onlyWithImage;
  final _ReviewSortMode sortMode;
  final List<ProductReview> filteredReviews;
  final ValueChanged<int?> onRatingFilterChanged;
  final ValueChanged<_ReviewSortMode> onSortChanged;
  final VoidCallback onToggleOnlyWithImage;

  int _countByStar(int star) {
    var count = 0;
    for (final review in product.reviews) {
      if (review.rating == star) {
        count++;
      }
    }
    return count;
  }

  double _ratioByStar(int star) {
    if (product.reviews.isEmpty) {
      return 0;
    }
    return _countByStar(star) / product.reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Danh gia san pham',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${product.averageRating.toStringAsFixed(1)} / 5',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFFE85D04),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final ratio = _ratioByStar(star);
                final count = _countByStar(star);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$star*',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFEDEDED),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFE85D04),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 24,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Sap xep:'),
              DropdownButton<_ReviewSortMode>(
                value: sortMode,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                    value: _ReviewSortMode.newest,
                    child: Text('Moi nhat'),
                  ),
                  DropdownMenuItem(
                    value: _ReviewSortMode.highest,
                    child: Text('Sao cao'),
                  ),
                  DropdownMenuItem(
                    value: _ReviewSortMode.lowest,
                    child: Text('Sao thap'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onSortChanged(value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  selected: selectedRating == null,
                  label: const Text('Tat ca'),
                  onSelected: (_) => onRatingFilterChanged(null),
                ),
                const SizedBox(width: 8),
                ...List.generate(5, (i) {
                  final star = i + 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: selectedRating == star,
                      label: Text('$star sao'),
                      onSelected: (_) => onRatingFilterChanged(star),
                    ),
                  );
                }),
                FilterChip(
                  selected: onlyWithImage,
                  label: const Text('Co hinh anh'),
                  onSelected: (_) => onToggleOnlyWithImage(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (filteredReviews.isEmpty)
            Text(
              'Chua co danh gia phu hop bo loc',
              style: theme.textTheme.bodyMedium,
            )
          else
            ...filteredReviews.map(
              (review) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEDEDED)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(
                          review.rating,
                          (index) => const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFFFAB00),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(review.comment),
                    if (review.hasImage) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          review.imageUrl!,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShopPolicySection extends StatelessWidget {
  const _ShopPolicySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chinh sach shop',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text('• Doi tra trong 30 ngay neu loi nha san xuat'),
            Text('• Bao hanh de giay 6 thang'),
            Text('• Giao nhanh du kien 2-4 ngay noi thanh'),
          ],
        ),
      ),
    );
  }
}

class _RelatedProductsSection extends StatelessWidget {
  const _RelatedProductsSection({required this.related});

  final List<RelatedProduct> related;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Co the ban cung thich',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 206,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: related.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = related[index];
                return SizedBox(
                  width: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item.imageUrl,
                          height: 120,
                          width: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(item.price, 'VND'),
                        style: const TextStyle(
                          color: Color(0xFFE03131),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.cartCount,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.isOutOfStock,
  });

  final int cartCount;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool isOutOfStock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 390;
          final buttonHeight = isCompact ? 44.0 : 46.0;

          Widget addToCartButton({required double height}) {
            return SizedBox(
              height: height,
              child: OutlinedButton(
                onPressed: isOutOfStock ? null : onAddToCart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Thêm giỏ hàng',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            );
          }

          Widget buyNowButton({required double height}) {
            return SizedBox(
              height: height,
              child: FilledButton(
                onPressed: isOutOfStock ? null : onBuyNow,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isOutOfStock ? 'Hết hàng' : 'Mua ngay',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: buttonHeight,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _IconAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Chat',
                    onTap: () {},
                  ),
                ),
              ),
              const SizedBox(width: 2),
              SizedBox(
                height: buttonHeight,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _AnimatedCartBadge(
                    count: cartCount,
                    child: _AnimatedCartAction(
                      label: 'Giỏ hàng',
                      onTap: () {},
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: addToCartButton(height: buttonHeight)),
              const SizedBox(width: 8),
              Expanded(child: buyNowButton(height: buttonHeight)),
            ],
          );
        },
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: const Color(0xFF555555)),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF555555)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCartBadge extends StatelessWidget {
  const _AnimatedCartBadge({required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (widget, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(scale: curved, child: widget);
      },
      child: Badge.count(
        key: ValueKey<int>(count),
        count: count,
        isLabelVisible: count > 0,
        backgroundColor: const Color(0xFFE03131),
        child: child,
      ),
    );
  }
}

class _AnimatedCircleCartButton extends StatefulWidget {
  const _AnimatedCircleCartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_AnimatedCircleCartButton> createState() =>
      _AnimatedCircleCartButtonState();
}

class _AnimatedCircleCartButtonState extends State<_AnimatedCircleCartButton> {
  bool _active = false;

  Future<void> _handleTap() async {
    widget.onTap();
    setState(() {
      _active = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) {
      return;
    }
    setState(() {
      _active = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: _active ? const Color(0xFFE03131) : Colors.black38,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: _handleTap,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        icon: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          scale: _active ? 1.22 : 1,
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _AnimatedCartAction extends StatefulWidget {
  const _AnimatedCartAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_AnimatedCartAction> createState() => _AnimatedCartActionState();
}

class _AnimatedCartActionState extends State<_AnimatedCartAction> {
  bool _active = false;

  Future<void> _handleTap() async {
    widget.onTap();
    setState(() {
      _active = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 170));
    if (!mounted) {
      return;
    }
    setState(() {
      _active = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _active ? const Color(0xFFE85D04) : const Color(0xFF555555);

    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 170),
              curve: Curves.easeOutBack,
              scale: _active ? 1.2 : 1,
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 170),
              style: TextStyle(fontSize: 10, color: color),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../controllers/cart_controller.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/expandable_text.dart';
import '../widgets/image_slider.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/product_price_section.dart';
import '../widgets/related_products.dart';
import '../widgets/review_section.dart';
import '../widgets/variation_selector.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final List<Product> allProducts;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.allProducts = const [],
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _sliderIndexNotifier = ValueNotifier<int>(0);
  final GlobalKey _cartIconKey = GlobalKey();

  bool _showScrollToTop = false;
  bool _isWishlisted = false;
  bool _showFlyingImage = false;
  bool _uiLoading = true;

  Offset _flyStart = const Offset(120, 550);
  Offset _flyEnd = const Offset(35, 25);

  late String _selectedSize;
  late String _selectedColor;
  late Duration _flashRemain;
  int _quantity = 1;

  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizes.first;
    _selectedColor = widget.product.colors.first;
    _flashRemain = const Duration(hours: 3, minutes: 45, seconds: 20);

    _scrollController.addListener(() {
      final visible = _scrollController.offset > 500;
      if (visible != _showScrollToTop) {
        setState(() => _showScrollToTop = visible);
      }
    });

    _flashTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_flashRemain.inSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() => _flashRemain -= const Duration(seconds: 1));
      }
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _uiLoading = false);
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _scrollController.dispose();
    _sliderIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final related = widget.allProducts
        .where((item) => widget.product.relatedProducts.contains(item.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _sliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageSlider(
                      heroTag: widget.product.id,
                      images: widget.product.images,
                      externalIndex: _sliderIndexNotifier,
                    ),
                    ProductPriceSection(
                      product: widget.product,
                      isLoading: _uiLoading,
                    ),
                    const SizedBox(height: 8),
                    _FlashSaleCountdown(remaining: _flashRemain),
                    const SizedBox(height: 8),
                    const _VoucherSection(),
                    const SizedBox(height: 8),
                    _variationTile(),
                    const SizedBox(height: 8),
                    const _ShippingInfoSection(),
                    const SizedBox(height: 8),
                    _descriptionSection(),
                    const SizedBox(height: 8),
                    ReviewSection(product: widget.product),
                    const SizedBox(height: 8),
                    RelatedProducts(
                      products: related,
                      onSelect: (product) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              product: product,
                              allProducts: widget.allProducts,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ],
          ),
          _buildFlyingImage(),
        ],
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              backgroundColor: const Color(0xFFEE4D2D),
              foregroundColor: Colors.white,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                );
              },
              child: const Icon(Icons.keyboard_arrow_up_rounded),
            )
          : null,
      bottomNavigationBar: Consumer<CartController>(
        builder: (_, cart, __) => BottomActionBar(
          cartCount: cart.cartCount,
          cartIconKey: _cartIconKey,
          onAddToCart: _onAddToCart,
          onBuyNow: _onBuyNow,
        ),
      ),
    );
  }

  SliverAppBar _sliverAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0.6,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Chi tiết sản phẩm',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() => _isWishlisted = !_isWishlisted);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isWishlisted
                      ? 'Đã thêm vào danh sách yêu thích'
                      : 'Đã bỏ khỏi yêu thích',
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 1100),
              ),
            );
          },
          icon: Icon(
            _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border,
            color: _isWishlisted ? const Color(0xFFEE4D2D) : Colors.black87,
          ),
        ),
        IconButton(
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(
                text: 'https://shop.demo/products/${widget.product.id}',
              ),
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã copy link sản phẩm'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.share_outlined),
        ),
        Consumer<CartController>(
          builder: (_, cart, __) => badges.Badge(
            showBadge: cart.cartCount > 0,
            position: badges.BadgePosition.topEnd(top: 5, end: 5),
            badgeStyle: const badges.BadgeStyle(badgeColor: Color(0xFFEE4D2D)),
            badgeContent: Text(
              '${cart.cartCount}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ),
        const SizedBox(width: 2),
      ],
    );
  }

  Widget _variationTile() {
    return InkWell(
      onTap: () {
        _openSelectorSheet();
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phân loại',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size $_selectedSize • Màu $_selectedColor • Số lượng $_quantity',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _descriptionSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả sản phẩm',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          ExpandableText(text: widget.product.description),
        ],
      ),
    );
  }

  Future<bool> _openSelectorSheet() async {
    final result = await showModalBottomSheet<_SheetSelection>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        String tempSize = _selectedSize;
        String tempColor = _selectedColor;
        int tempQty = _quantity;

        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.35,
          initialChildSize: 0.58,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return StatefulBuilder(
              builder: (_, setInnerState) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.product.images.first,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatPrice(widget.product.price),
                                style: const TextStyle(
                                  color: Color(0xFFEE4D2D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Đã chọn: $tempSize, $tempColor',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    VariationSelector(
                      title: 'Chọn Size',
                      values: widget.product.sizes,
                      selectedValue: tempSize,
                      disabledValues: widget.product.outOfStockSizes,
                      onSelected: (value) =>
                          setInnerState(() => tempSize = value),
                    ),
                    const SizedBox(height: 16),
                    VariationSelector(
                      title: 'Chọn Màu',
                      values: widget.product.colors,
                      selectedValue: tempColor,
                      disabledValues: widget.product.outOfStockColors,
                      onSelected: (value) {
                        setInnerState(() => tempColor = value);
                        final mapped = widget.product.colorImageMap[value] ?? 0;
                        _sliderIndexNotifier.value = mapped;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Số lượng',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        QuantitySelector(
                          quantity: tempQty,
                          onChanged: (value) =>
                              setInnerState(() => tempQty = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(
                            context,
                            _SheetSelection(
                              size: tempSize,
                              color: tempColor,
                              quantity: tempQty,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEE4D2D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'XÁC NHẬN',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return false;
    setState(() {
      _selectedSize = result.size;
      _selectedColor = result.color;
      _quantity = result.quantity;
    });
    return true;
  }

  Future<void> _onAddToCart() async {
    HapticFeedback.lightImpact();
    final confirmed = await _openSelectorSheet();
    if (!confirmed) return;
    if (!mounted) return;

    await _playFlyToCart();
    if (!mounted) return;

    context.read<CartController>().addToCart(
      widget.product,
      _selectedSize,
      _selectedColor,
      _quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm vào giỏ hàng'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onBuyNow() async {
    await _onAddToCart();
  }

  Future<void> _playFlyToCart() async {
    final box = _cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final end = box.localToGlobal(Offset.zero);
    final screen = MediaQuery.of(context).size;

    setState(() {
      _flyStart = Offset(screen.width * 0.5 - 24, screen.height - 140);
      _flyEnd = Offset(end.dx, end.dy);
      _showFlyingImage = true;
    });

    await Future.delayed(const Duration(milliseconds: 620));
    if (!mounted) return;
    setState(() => _showFlyingImage = false);
  }

  Widget _buildFlyingImage() {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedPositioned(
        duration: const Duration(milliseconds: 620),
        curve: Curves.easeInOutCubic,
        left: _showFlyingImage ? _flyEnd.dx : _flyStart.dx,
        top: _showFlyingImage ? _flyEnd.dy : _flyStart.dy,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 620),
          opacity: _showFlyingImage ? 1 : 0,
          child: Transform.scale(
            scale: _showFlyingImage ? 0.42 : 1,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product.images.first,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final value = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) buffer.write('.');
      buffer.write(value[i]);
    }
    return '$bufferđ';
  }
}

class _SheetSelection {
  final String size;
  final String color;
  final int quantity;

  const _SheetSelection({
    required this.size,
    required this.color,
    required this.quantity,
  });
}

class _FlashSaleCountdown extends StatelessWidget {
  final Duration remaining;

  const _FlashSaleCountdown({required this.remaining});

  @override
  Widget build(BuildContext context) {
    String pad(int value) => value.toString().padLeft(2, '0');

    final hh = pad(remaining.inHours);
    final mm = pad(remaining.inMinutes % 60);
    final ss = pad(remaining.inSeconds % 60);

    Widget chip(String value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          const Icon(Icons.flash_on_rounded, color: Color(0xFFFF9800)),
          const SizedBox(width: 6),
          const Text(
            'Flash Sale',
            style: TextStyle(
              color: Color(0xFFEE4D2D),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          chip(hh),
          const SizedBox(width: 4),
          chip(mm),
          const SizedBox(width: 4),
          chip(ss),
        ],
      ),
    );
  }
}

class _VoucherSection extends StatelessWidget {
  const _VoucherSection();

  @override
  Widget build(BuildContext context) {
    const vouchers = ['Giảm 15k', 'Freeship 25k', 'Giảm 10% tối đa 40k'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          const Text('Voucher', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: vouchers
                    .map(
                      (voucher) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFEE4D2D)),
                          color: const Color(
                            0xFFEE4D2D,
                          ).withValues(alpha: 0.08),
                        ),
                        child: Text(
                          voucher,
                          style: const TextStyle(
                            color: Color(0xFFEE4D2D),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}

class _ShippingInfoSection extends StatelessWidget {
  const _ShippingInfoSection();

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String text) {
      return Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin vận chuyển',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          row(Icons.local_shipping_outlined, 'Nhận hàng dự kiến 2 - 4 ngày'),
          const SizedBox(height: 8),
          row(Icons.verified_outlined, 'Đồng kiểm trước khi nhận hàng'),
          const SizedBox(height: 8),
          row(Icons.location_on_outlined, 'Giao từ kho Hồ Chí Minh'),
        ],
      ),
    );
  }
}

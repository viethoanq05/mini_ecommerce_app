import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/home_controller.dart';
import '../controllers/product_detail_controller.dart';
import '../controllers/cart_provider.dart';
import '../models/product_item.dart';
import 'product_detail_screen.dart';
import '../widgets/home/home_banner_carousel.dart';
import '../widgets/home/home_category_card.dart';
import '../widgets/home/home_product_card.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/home/home_section_header.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController(
    viewportFraction: 0.92,
  );
  final HomeController _controller = HomeController();
  Timer? _bannerTimer;

  bool _isAppBarCollapsed = false;
  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _controller.addListener(_onControllerChanged);
    _controller.loadInitialData();
    _startBannerAutoPlay();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _bannerController.dispose();
    _bannerTimer?.cancel();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      if (_currentBanner >= _controller.banners.length &&
          _controller.banners.isNotEmpty) {
        _currentBanner = 0;
      }
      setState(() {});
    }
  }

  void _startBannerAutoPlay() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerController.hasClients || _controller.banners.length <= 1) {
        return;
      }

      final nextPage = (_currentBanner + 1) % _controller.banners.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _handleScroll() {
    final isCollapsed =
        _scrollController.hasClients && _scrollController.offset > 36;
    if (isCollapsed != _isAppBarCollapsed) {
      setState(() {
        _isAppBarCollapsed = isCollapsed;
      });
    }

    if (!_scrollController.hasClients ||
        _controller.isLoadingMore ||
        !_controller.hasNextPage) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels > position.maxScrollExtent - 480) {
      _controller.loadMoreProducts();
    }
  }

  void _openProductDetail(BuildContext context, ProductItem item) {
    final detailProvider = context.read<ProductDetailController>();
    detailProvider.selectFromItem(item);
    final selected = detailProvider.selectedProduct;
    if (selected == null) {
      return;
    }

    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: selected)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final width = size.width;
    final horizontalPadding = width < 360
        ? 12.0
        : width < 700
        ? 16.0
        : 22.0;
    final bannerHeight = (width * 0.44).clamp(150.0, 220.0);
    final searchHeight = width < 360 ? 40.0 : 46.0;
    final toolbarHeight = width < 360 ? 60.0 : 66.0;
    final categoriesHeight = width < 360 ? 242.0 : 256.0;
    final productColumns = width >= 1100
        ? 4
        : width >= 760
        ? 3
        : 2;
    final productSpacing = width >= 700 ? 16.0 : 14.0;
    final productAspectRatio = width >= 1000
        ? 0.72
        : width >= 700
        ? 0.63
        : width < 360
        ? 0.5
        : 0.54;

    if (_controller.isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_controller.errorMessage != null && _controller.products.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48),
                const SizedBox(height: 12),
                Text(
                  _controller.errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _controller.loadInitialData,
                  child: const Text('Tải lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: _controller.refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: toolbarHeight + searchHeight + 16,
              toolbarHeight: toolbarHeight,
              backgroundColor: _isAppBarCollapsed
                  ? colorScheme.primary
                  : Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: _isAppBarCollapsed ? 4 : 0,
              titleSpacing: horizontalPadding,
              title: Text(
                'TH4 - Nhóm 12',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _isAppBarCollapsed
                      ? Colors.white
                      : colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(searchHeight + 10),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    10,
                  ),
                  child: HomeSearchBar(
                    isCollapsed: _isAppBarCollapsed,
                    height: searchHeight,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: horizontalPadding),
                  child: Consumer<CartProvider>(
                    builder: (context, cart, child) => Badge.count(
                      count: cart.itemCount,
                      backgroundColor: const Color(0xFFE03131),
                      textColor: Colors.white,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.shopping_cart_outlined,
                          color: _isAppBarCollapsed
                              ? Colors.white
                              : colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  0,
                ),
                child: HomeBannerCarousel(
                  controller: _bannerController,
                  banners: _controller.banners,
                  currentIndex: _currentBanner,
                  bannerHeight: bannerHeight,
                  onPageChanged: (index) {
                    if (_currentBanner == index) {
                      return;
                    }
                    setState(() {
                      _currentBanner = index;
                    });
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  8,
                ),
                child: const HomeSectionHeader(
                  title: 'Danh mục nổi bật',
                  subtitle: 'Lướt nhanh những ngành hàng đang có ưu đãi tốt.',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: categoriesHeight,
                child: Padding(
                  padding: EdgeInsets.only(left: horizontalPadding),
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.02,
                        ),
                    itemCount: _controller.categories.length,
                    itemBuilder: (context, index) {
                      return HomeCategoryCard(
                        category: _controller.categories[index],
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
                  horizontalPadding,
                  12,
                ),
                child: const HomeSectionHeader(
                  title: 'Gợi ý hôm nay',
                  subtitle:
                      'Làm mới để mô phỏng feed, kéo xuống đáy để tải thêm.',
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return HomeProductCard(
                    product: _controller.products[index],
                    isCompact: width < 360,
                    onTap: () => _openProductDetail(
                      context,
                      _controller.products[index],
                    ),
                  );
                }, childCount: _controller.products.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: productColumns,
                  mainAxisSpacing: productSpacing,
                  crossAxisSpacing: productSpacing,
                  childAspectRatio: productAspectRatio,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  18,
                  horizontalPadding,
                  28,
                ),
                child: Center(
                  child: _controller.isLoadingMore
                      ? const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text('Đang tải thêm sản phẩm...'),
                          ],
                        )
                      : Text(
                          _controller.hasNextPage
                              ? 'Tiếp tục cuộn để tải trang kế tiếp.'
                              : 'Bạn đã xem hết danh sách mẫu.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

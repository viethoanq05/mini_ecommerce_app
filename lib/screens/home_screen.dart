import 'dart:async';

import 'package:flutter/material.dart';

import '../models/banner_item.dart';
import '../models/category_item.dart';
import '../models/home_initial_data.dart';
import '../models/home_product_page.dart';
import '../models/product_item.dart';
import '../screens/cart_screen.dart';
import '../services/home_repository.dart';
import '../services/mock_home_data.dart';
import '../services/mock_home_repository.dart';
import '../widgets/product_card.dart';
import '../widgets/home/home_banner_carousel.dart';
import '../widgets/home/home_category_card.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/home/home_section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, HomeRepository? repository})
      : repository = repository ?? const MockHomeRepository();

  final HomeRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController(
    viewportFraction: 0.92,
  );

  late final List<BannerItem> _banners;
  late final List<CategoryItem> _categories;
  final List<ProductItem> _products = [];

  Timer? _bannerTimer;
  late final HomeRepository _repository;
  bool _isAppBarCollapsed = false;
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasNextPage = true;
  String? _errorMessage;
  int _page = 0;
  int _currentBanner = 0;
  int _cartItemTypes = 0;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository;
    _banners = <BannerItem>[];
    _categories = <CategoryItem>[];
    _scrollController.addListener(_handleScroll);
    _startBannerAutoPlay();
    unawaited(_loadInitialData());
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing || _isInitialLoading) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final initialDataFuture = _repository.fetchInitialData();
      final firstPageFuture = _repository.fetchProductsPage(
        page: 0,
        pageSize: defaultPageSize,
      );
      final results = await Future.wait<Object>([
        initialDataFuture,
        firstPageFuture,
      ]);

      if (!mounted) {
        return;
      }

      final initialData = results[0] as HomeInitialData;
      final firstPage = results[1] as HomeProductPage;

      setState(() {
        _page = 0;
        _cartItemTypes = initialData.cartItemTypes;
        _banners
          ..clear()
          ..addAll(initialData.banners);
        _categories
          ..clear()
          ..addAll(initialData.categories);
        _products
          ..clear()
          ..addAll(firstPage.items);
        _hasNextPage = firstPage.hasNextPage;
        _errorMessage = null;
        _isRefreshing = false;
      });

      return;
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Không thể làm mới dữ liệu. Thử lại sau.';
        _isRefreshing = false;
      });
      return;
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final initialDataFuture = _repository.fetchInitialData();
      final firstPageFuture = _repository.fetchProductsPage(
        page: 0,
        pageSize: defaultPageSize,
      );
      final results = await Future.wait<Object>([
        initialDataFuture,
        firstPageFuture,
      ]);

      if (!mounted) {
        return;
      }

      final initialData = results[0] as HomeInitialData;
      final firstPage = results[1] as HomeProductPage;

      setState(() {
        _page = 0;
        _cartItemTypes = initialData.cartItemTypes;
        _banners
          ..clear()
          ..addAll(initialData.banners);
        _categories
          ..clear()
          ..addAll(initialData.categories);
        _products
          ..clear()
          ..addAll(firstPage.items);
        _hasNextPage = firstPage.hasNextPage;
        _isInitialLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitialLoading = false;
        _errorMessage = 'Không thể tải dữ liệu trang chủ.';
      });
    }
  }

  void _handleScroll() {
    final isCollapsed =
        _scrollController.hasClients && _scrollController.offset > 36;
    if (isCollapsed != _isAppBarCollapsed) {
      setState(() {
        _isAppBarCollapsed = isCollapsed;
      });
    }

    if (!_scrollController.hasClients || _isLoadingMore || !_hasNextPage) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels > position.maxScrollExtent - 480) {
      unawaited(_loadMoreProducts());
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasNextPage) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _page + 1;
      final productPage = await _repository.fetchProductsPage(
        page: nextPage,
        pageSize: defaultPageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _page = nextPage;
        _products.addAll(productPage.items);
        _hasNextPage = productPage.hasNextPage;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _startBannerAutoPlay() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerController.hasClients || _banners.isEmpty) {
        return;
      }

      final nextPage = (_currentBanner + 1) % _banners.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
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
    final categoriesHeight = width < 360 ? 204.0 : 228.0;
    final productColumns = width >= 1100
        ? 4
        : width >= 760
            ? 3
            : 2;
    final productAspectRatio = width >= 760 ? 0.75 : 0.72;

    if (_isInitialLoading) {
      return Scaffold(
        body: SafeArea(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: productColumns,
              childAspectRatio: productAspectRatio,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, __) => const ProductCardShimmer(),
          ),
        ),
      );
    }

    if (_errorMessage != null && _products.isEmpty) {
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
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _isInitialLoading = true;
                      _errorMessage = null;
                    });
                    unawaited(_loadInitialData());
                  },
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
        onRefresh: _handleRefresh,
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
              backgroundColor:
                  _isAppBarCollapsed ? colorScheme.primary : Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: _isAppBarCollapsed ? 4 : 0,
              titleSpacing: horizontalPadding,
              title: Text(
                'TH4 - Nhóm 12',
                style: theme.textTheme.titleMedium?.copyWith(
                  color:
                      _isAppBarCollapsed ? Colors.white : colorScheme.primary,
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
                  child: Badge.count(
                    count: _cartItemTypes,
                    backgroundColor: const Color(0xFFE03131),
                    textColor: Colors.white,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CartScreen(),
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
                  banners: _banners,
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
                  actionLabel: 'Xem tất cả',
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
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return HomeCategoryCard(category: _categories[index]);
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
                  actionLabel: 'Bộ lọc',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: productColumns,
                  childAspectRatio: productAspectRatio,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: _products[index]);
                },
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
                  child: _isLoadingMore
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
                          !_hasNextPage
                              ? 'Bạn đã xem hết danh sách mẫu.'
                              : 'Tiếp tục cuộn để tải trang kế tiếp.',
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

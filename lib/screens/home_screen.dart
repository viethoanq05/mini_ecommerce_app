import 'package:flutter/material.dart';

import '../controllers/home_controller.dart';
import '../models/banner_item.dart';
import '../models/category_item.dart';
import '../models/home_initial_data.dart';
import '../models/home_product_page.dart';
import '../models/product_item.dart';
import '../services/home_repository.dart';
import '../services/mock_home_data.dart';
import '../services/mock_home_repository.dart';
import '../widgets/product_card.dart';
import '../widgets/home/home_banner_carousel.dart';
import '../widgets/home/home_category_card.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/home/home_section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
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

  final HomeController _controller = HomeController();
  bool _isAppBarCollapsed = false;
  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _controller.loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bannerController.dispose();
    _controller.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final width = size.width;
    final horizontalPadding = width < 360 ? 12.0 : (width < 700 ? 16.0 : 22.0);
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
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(searchHeight + 10),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: HomeSearchBar(isCollapsed: _isAppBarCollapsed, height: searchHeight),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                    child: HomeBannerCarousel(
                      controller: _bannerController,
                      banners: _controller.banners,
                      currentIndex: _currentBanner,
                      bannerHeight: bannerHeight,
                      onPageChanged: (index) => setState(() => _currentBanner = index),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 8),
                    child: const HomeSectionHeader(
                      title: 'Danh mục nổi bật',
                      subtitle: 'Khám phá ngay',
                      actionLabel: 'Xem tất cả',
                    ),
                  ),
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
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return HomeProductCard(product: _controller.products[index], isCompact: width < 360);
                    }, childCount: _controller.products.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: productColumns,
                      mainAxisSpacing: productSpacing,
                      crossAxisSpacing: productSpacing,
                      childAspectRatio: productAspectRatio,
                    ),
                  ),
                ),
                if (_controller.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

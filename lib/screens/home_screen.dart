import 'package:flutter/material.dart';

import '../controllers/home_controller.dart';
import '../widgets/home/home_banner_carousel.dart';
import '../widgets/home/home_category_card.dart';
import '../widgets/home/home_product_card.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/home/home_section_header.dart';

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
    final productColumns = width >= 1000 ? 4 : (width >= 700 ? 3 : 2);
    final productSpacing = width >= 700 ? 16.0 : 14.0;
    final productAspectRatio = width >= 1000 ? 0.72 : (width >= 700 ? 0.63 : (width < 360 ? 0.5 : 0.54));

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isInitialLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _controller.refreshData,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: toolbarHeight + searchHeight + 16,
                  toolbarHeight: toolbarHeight,
                  backgroundColor: _isAppBarCollapsed ? colorScheme.primary : Colors.transparent,
                  title: Text(
                    'Mini Ecommerce',
                    style: TextStyle(color: _isAppBarCollapsed ? Colors.white : colorScheme.primary),
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
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: categoriesHeight,
                    child: Padding(
                      padding: EdgeInsets.only(left: horizontalPadding),
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.02,
                        ),
                        itemCount: _controller.categories.length,
                        itemBuilder: (context, index) => HomeCategoryCard(category: _controller.categories[index]),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 12),
                    child: const HomeSectionHeader(
                      title: 'Gợi ý hôm nay',
                      subtitle: 'Sản phẩm mới nhất',
                      actionLabel: 'Lọc',
                    ),
                  ),
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

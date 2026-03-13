import 'package:flutter/material.dart';
import '../models/banner_item.dart';
import '../models/category_item.dart';
import '../models/product_item.dart';
import '../services/product_service.dart';
import '../services/mock_home_data.dart';

class HomeController extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<BannerItem> banners = [];
  List<CategoryItem> categories = [];
  List<ProductItem> products = [];

  bool isInitialLoading = true;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool hasNextPage = true;
  String? errorMessage;
  int _currentPage = 0;
  final int _pageSize = 8;

  Future<void> loadInitialData() async {
    isInitialLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Mock data for banners (as API doesn't provide them)
      banners = buildMockBanners();

      // Fetch real categories and products in parallel
      final results = await Future.wait([
        _productService.getAllCategories(),
        _productService.getAll(),
      ]);

      categories = results[0] as List<CategoryItem>;
      final allProducts = results[1] as List<ProductItem>;

      _currentPage = 0;
      _updateProductsList(allProducts);

      isInitialLoading = false;
    } catch (e) {
      // Fallback for offline mode / tests to keep home screen renderable.
      _loadLocalFallback();
      isInitialLoading = false;
      errorMessage = null;
    }
    notifyListeners();
  }

  void _loadLocalFallback() {
    categories = buildMockCategories();
    _currentPage = 0;
    products = generateMockProducts(page: 0, pageSize: _pageSize);
    hasNextPage = true;
  }

  void _updateProductsList(List<ProductItem> allProducts) {
    int start = _currentPage * _pageSize;
    int end = start + _pageSize;

    if (start < allProducts.length) {
      var sublist = allProducts.sublist(
        start,
        end > allProducts.length ? allProducts.length : end,
      );
      if (_currentPage == 0) {
        products = List.from(sublist);
      } else {
        products.addAll(sublist);
      }
      hasNextPage = end < allProducts.length;
    } else {
      hasNextPage = false;
    }
  }

  Future<void> refreshData() async {
    if (isRefreshing) return;
    isRefreshing = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _productService.getAllCategories(),
        _productService.getAll(),
      ]);

      categories = results[0] as List<CategoryItem>;
      final allProducts = results[1] as List<ProductItem>;

      _currentPage = 0;
      _updateProductsList(allProducts);
      errorMessage = null;
    } catch (e) {
      _loadLocalFallback();
      errorMessage = null;
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMore || !hasNextPage) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      // Re-fetching to simulate pagination from a static API
      final allProducts = await _productService.getAll();
      _currentPage++;
      _updateProductsList(allProducts);
    } catch (e) {
      // Fallback pagination for offline mode / tests.
      _currentPage++;
      products.addAll(
        generateMockProducts(page: _currentPage, pageSize: _pageSize),
      );
      hasNextPage = _currentPage < 3;
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }
}

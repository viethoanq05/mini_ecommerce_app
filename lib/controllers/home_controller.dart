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
      // Mock data for UI components not in API
      banners = buildMockBanners();
      categories = buildMockCategories();
      
      // Real data from API
      final allProducts = await _productService.getAll();
      _currentPage = 0;
      _updateProductsList(allProducts);
      
      isInitialLoading = false;
    } catch (e) {
      isInitialLoading = false;
      errorMessage = 'Không thể tải dữ liệu: $e';
    }
    notifyListeners();
  }

  void _updateProductsList(List<ProductItem> allProducts) {
    int start = _currentPage * _pageSize;
    int end = start + _pageSize;
    
    if (start < allProducts.length) {
      var sublist = allProducts.sublist(
        start, 
        end > allProducts.length ? allProducts.length : end
      );
      if (_currentPage == 0) {
        products = sublist;
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
      final allProducts = await _productService.getAll();
      _currentPage = 0;
      _updateProductsList(allProducts);
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Không thể làm mới dữ liệu.';
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
      // Since FakeStore doesn't support real pagination well in some cases,
      // we re-fetch (or would ideally have a better API) 
      // but here we simulate from the loaded list for performance
      final allProducts = await _productService.getAll();
      _currentPage++;
      _updateProductsList(allProducts);
    } catch (e) {
      // Silent error
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }
}

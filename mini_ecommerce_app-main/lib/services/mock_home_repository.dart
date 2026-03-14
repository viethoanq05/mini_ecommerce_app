import '../models/home_initial_data.dart';
import '../models/home_product_page.dart';
import 'home_repository.dart';
import 'mock_home_data.dart';

class MockHomeRepository implements HomeRepository {
  const MockHomeRepository();

  static const int _mockMaxPages = 4;
  static const int _mockCartItemTypes = 3;

  @override
  Future<HomeInitialData> fetchInitialData() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return HomeInitialData(
      banners: buildMockBanners(),
      categories: buildMockCategories(),
      cartItemTypes: _mockCartItemTypes,
    );
  }

  @override
  Future<HomeProductPage> fetchProductsPage({
    required int page,
    int pageSize = defaultPageSize,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    return HomeProductPage(
      items: generateMockProducts(page: page, pageSize: pageSize),
      hasNextPage: page < _mockMaxPages - 1,
    );
  }
}

import '../models/home_initial_data.dart';
import '../models/home_product_page.dart';

abstract class HomeRepository {
  Future<HomeInitialData> fetchInitialData();

  Future<HomeProductPage> fetchProductsPage({required int page, int pageSize});
}

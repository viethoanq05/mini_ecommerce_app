import 'banner_item.dart';
import 'category_item.dart';

class HomeInitialData {
  const HomeInitialData({
    required this.banners,
    required this.categories,
    required this.cartItemTypes,
  });

  final List<BannerItem> banners;
  final List<CategoryItem> categories;
  final int cartItemTypes;
}

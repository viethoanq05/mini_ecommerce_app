import 'product_item.dart';

class HomeProductPage {
  const HomeProductPage({required this.items, required this.hasNextPage});

  final List<ProductItem> items;
  final bool hasNextPage;
}

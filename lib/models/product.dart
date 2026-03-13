class ProductReview {
  final String user;
  final double rating;
  final String comment;
  final String date;

  const ProductReview({
    required this.user,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

/// Model đại diện cho một sản phẩm trong ứng dụng e-commerce.
class Product {
  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final List<String> images;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final List<ProductReview> reviews;
  final List<String> relatedProducts;
  final List<String> outOfStockSizes;
  final List<String> outOfStockColors;
  final Map<String, int> colorImageMap;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.images,
    required this.description,
    required this.sizes,
    required this.colors,
    this.rating = 4.8,
    this.reviews = const [],
    this.relatedProducts = const [],
    this.outOfStockSizes = const [],
    this.outOfStockColors = const [],
    this.colorImageMap = const {},
  });
}

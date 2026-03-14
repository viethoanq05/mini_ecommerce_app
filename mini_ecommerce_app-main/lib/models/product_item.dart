class ProductItem {
  const ProductItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.soldCount,
    required this.tags,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String currency;
  final int soldCount;
  final List<String> tags;
}

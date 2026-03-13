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

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'].toString(),
      name: json['title'] ?? '',
      imageUrl: json['image'] ?? '',
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] ?? '\$', 
      soldCount: json['rating'] != null 
          ? (json['rating']['count'] as num).toInt() 
          : (json['soldCount'] ?? 0),
      tags: json['category'] != null 
          ? [json['category'] as String] 
          : List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'image': imageUrl,
      'price': price,
      'currency': currency,
      'soldCount': soldCount,
      'tags': tags,
    };
  }
}

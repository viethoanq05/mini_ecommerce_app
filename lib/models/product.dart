class ProductVariant {
  const ProductVariant({
    required this.size,
    required this.color,
    required this.stock,
    this.price,
  });

  final String size;
  final String color;
  final int stock;
  final double? price;
}

class ProductReview {
  const ProductReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String userName;
  final int rating;
  final String comment;
  final String? imageUrl;
  final DateTime createdAt;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}

class ProductVoucher {
  const ProductVoucher({
    required this.id,
    required this.title,
    required this.discountAmount,
    this.minOrderValue = 0,
    this.isFreeship = false,
  });

  final String id;
  final String title;
  final double discountAmount;
  final double minOrderValue;
  final bool isFreeship;
}

class RelatedProduct {
  const RelatedProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double price;
}

/// Model sản phẩm đầy đủ dùng cho màn hình chi tiết.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.description,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.variants,
    required this.colorImages,
    required this.reviews,
    required this.vouchers,
    required this.relatedProducts,
  });

  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final String description;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;

  /// Bảng tồn kho theo từng tổ hợp Size + Color.
  final List<ProductVariant> variants;

  /// Map màu -> danh sách ảnh đại diện cho màu đó.
  final Map<String, List<String>> colorImages;

  final List<ProductReview> reviews;
  final List<ProductVoucher> vouchers;
  final List<RelatedProduct> relatedProducts;

  double get discountPercent => originalPrice > price
      ? ((originalPrice - price) / originalPrice * 100).roundToDouble()
      : 0;

  int stockOf(String size, String color) {
    for (final item in variants) {
      if (item.size == size && item.color == color) {
        return item.stock;
      }
    }
    return 0;
  }

  ProductVariant? variantOf(String size, String color) {
    for (final item in variants) {
      if (item.size == size && item.color == color) {
        return item;
      }
    }
    return null;
  }

  double priceOf(String size, String color) {
    final item = variantOf(size, color);
    if (item == null) {
      return price;
    }
    return item.price ?? price;
  }

  int totalStockByColor(String color) {
    var stock = 0;
    for (final item in variants) {
      if (item.color == color) {
        stock += item.stock;
      }
    }
    return stock;
  }

  int totalStockBySize(String size) {
    var stock = 0;
    for (final item in variants) {
      if (item.size == size) {
        stock += item.stock;
      }
    }
    return stock;
  }

  bool isColorAvailableForSize(String color, String size) {
    return stockOf(size, color) > 0;
  }

  bool isSizeAvailableForColor(String size, String color) {
    return stockOf(size, color) > 0;
  }

  int get totalStock {
    var total = 0;
    for (final item in variants) {
      total += item.stock;
    }
    return total;
  }

  double get averageRating {
    if (reviews.isEmpty) {
      return 0;
    }
    final sum = reviews.fold<int>(0, (value, item) => value + item.rating);
    return sum / reviews.length;
  }
}

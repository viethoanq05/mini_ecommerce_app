import '../models/product.dart';

class ProductService {
  static const List<Product> products = [
    Product(
      id: 'prod_001',
      name: 'Áo Thun Basic Unisex Form Rộng Cotton 100% Cao Cấp - Nhiều Màu',
      price: 149000,
      originalPrice: 299000,
      description:
          'Áo thun basic unisex form rộng được làm từ 100% cotton cao cấp, '
          'mềm mại và thoáng mát. Thiết kế đơn giản phù hợp nhiều phong cách. '
          'Kết hợp tốt với quần jeans, kaki hay chân váy đều đẹp. '
          'Màu sắc đa dạng, không phai sau nhiều lần giặt. '
          'Size S/M/L/XL/XXL phù hợp nhiều vóc dáng. '
          'Phù hợp đi chơi, đi học, đi làm casual hoặc ở nhà. '
          'Bảo hành đổi trả trong 7 ngày nếu lỗi do nhà sản xuất.',
      images: [
        'https://picsum.photos/seed/tshirt1/600/600',
        'https://picsum.photos/seed/tshirt2/600/600',
        'https://picsum.photos/seed/tshirt3/600/600',
        'https://picsum.photos/seed/tshirt4/600/600',
      ],
      sizes: ['S', 'M', 'L'],
      colors: ['Red', 'Blue', 'Green'],
      outOfStockSizes: ['L'],
      outOfStockColors: ['Green'],
      colorImageMap: {'Red': 0, 'Blue': 1, 'Green': 2},
      relatedProducts: ['prod_002', 'prod_003', 'prod_004'],
      reviews: [
        ProductReview(
          user: 'minhtran',
          rating: 5,
          comment: 'Áo mặc thoáng, màu đẹp, form giống mô tả.',
          date: '12/03/2026',
        ),
        ProductReview(
          user: 'hainguyen',
          rating: 4,
          comment: 'Chất ổn trong tầm giá, giao nhanh.',
          date: '10/03/2026',
        ),
        ProductReview(
          user: 'linhpham',
          rating: 5,
          comment: 'Shop đóng gói kỹ, sẽ mua lại.',
          date: '06/03/2026',
        ),
      ],
    ),
    Product(
      id: 'prod_002',
      name: 'Giày Sneaker Nam Nữ Đế Cao 5cm Cổ Thấp - Phong Cách Hàn Quốc',
      price: 349000,
      originalPrice: 699000,
      description:
          'Giày sneaker phong cách Hàn Quốc với đế cao 5cm giúp tôn chiều cao. '
          'Chất liệu da PU cao cấp, chống thấm nước, dễ vệ sinh. '
          'Đế EVA êm ái, giảm áp lực khi đi bộ nhiều. '
          'Thiết kế unisex phù hợp cả nam và nữ. '
          'Phù hợp đi dạo phố, đi học, đi làm casual.',
      images: [
        'https://picsum.photos/seed/shoes1/600/600',
        'https://picsum.photos/seed/shoes2/600/600',
        'https://picsum.photos/seed/shoes3/600/600',
      ],
      sizes: ['S', 'M', 'L'],
      colors: ['Red', 'Blue', 'Green'],
      outOfStockSizes: ['S'],
      colorImageMap: {'Red': 0, 'Blue': 1, 'Green': 2},
      relatedProducts: ['prod_001', 'prod_003'],
      reviews: [
        ProductReview(
          user: 'vietle',
          rating: 5,
          comment: 'Giày êm chân, đi cả ngày không đau.',
          date: '09/03/2026',
        ),
        ProductReview(
          user: 'anhtuyet',
          rating: 4,
          comment: 'Đúng size, kiểu dáng đẹp.',
          date: '05/03/2026',
        ),
      ],
    ),
    Product(
      id: 'prod_003',
      name: 'Túi Tote Canvas Vải Bao Tải In Hình Trendy Hàng Cao Cấp',
      price: 89000,
      originalPrice: 159000,
      description:
          'Túi tote canvas vải bao tải bền chắc, có thể đựng laptop, sách vở. '
          'Thiết kế đơn giản hiện đại, phù hợp đi học, đi làm, đi dạo. '
          'Có nhiều ngăn tiện dụng, dây đeo chắc chắn, tải trọng tốt. '
          'Có thể giặt máy, dễ vệ sinh.',
      images: [
        'https://picsum.photos/seed/bag1/600/600',
        'https://picsum.photos/seed/bag2/600/600',
      ],
      sizes: ['S', 'M', 'L'],
      colors: ['Red', 'Blue', 'Green'],
      outOfStockColors: ['Blue'],
      colorImageMap: {'Red': 0, 'Blue': 1, 'Green': 0},
      relatedProducts: ['prod_001', 'prod_004'],
      reviews: [
        ProductReview(
          user: 'thaoho',
          rating: 4,
          comment: 'Vải dày, cứng form, đáng tiền.',
          date: '11/03/2026',
        ),
      ],
    ),
    Product(
      id: 'prod_004',
      name: 'Kính Mắt Thời Trang Gọng Tròn Vintage Chống UV400',
      price: 129000,
      originalPrice: 250000,
      description:
          'Kính mắt thời trang gọng tròn phong cách vintage, chống tia UV400. '
          'Tròng kính trong sáng, không làm biến dạng màu sắc. '
          'Gọng nhẹ, không gây áp lực lên mũi. '
          'Phù hợp với nhiều kiểu mặt.',
      images: [
        'https://picsum.photos/seed/glasses1/600/600',
        'https://picsum.photos/seed/glasses2/600/600',
        'https://picsum.photos/seed/glasses3/600/600',
      ],
      sizes: ['S', 'M', 'L'],
      colors: ['Red', 'Blue', 'Green'],
      colorImageMap: {'Red': 0, 'Blue': 1, 'Green': 2},
      relatedProducts: ['prod_001', 'prod_002'],
      reviews: [
        ProductReview(
          user: 'dinhvu',
          rating: 5,
          comment: 'Đeo nhẹ mặt, hợp outfit.',
          date: '08/03/2026',
        ),
        ProductReview(
          user: 'hoanglan',
          rating: 4,
          comment: 'Sản phẩm đẹp như ảnh.',
          date: '02/03/2026',
        ),
      ],
    ),
  ];
}

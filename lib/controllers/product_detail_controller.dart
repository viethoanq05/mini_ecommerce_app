import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/product_item.dart';

class ProductDetailController extends ChangeNotifier {
  Product? _selectedProduct;

  Product? get selectedProduct => _selectedProduct;

  void selectFromItem(ProductItem item) {
    final originalPrice = item.price > 0 ? item.price * 2 : item.price;
    _selectedProduct = Product(
      id: item.id,
      name: item.name,
      price: item.price,
      originalPrice: originalPrice,
      description:
          'San pham chat luong cao voi thiet ke hien dai, phu hop nhieu phong cach. '
          'Chat lieu ben dep va thoai mai khi su dung hang ngay.\n\n'
          'Dac diem noi bat:\n'
          '- Chat lieu cao cap, mem nhe\n'
          '- De phoi do, phu hop di hoc di lam\n'
          '- Chinh sach doi tra 30 ngay neu co loi nha san xuat.',
      images: [
        item.imageUrl,
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1200',
        'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=1200',
      ],
      sizes: const ['S', 'M', 'L', 'XL'],
      colors: const ['Do', 'Xanh Navy', 'Den', 'Trang'],
      variants: [
        ProductVariant(size: 'S', color: 'Do', stock: 3, price: item.price),
        ProductVariant(size: 'S', color: 'Den', stock: 0, price: item.price),
        ProductVariant(
          size: 'M',
          color: 'Do',
          stock: 2,
          price: item.price + 10000,
        ),
        ProductVariant(
          size: 'M',
          color: 'Xanh Navy',
          stock: 7,
          price: item.price + 12000,
        ),
        ProductVariant(
          size: 'M',
          color: 'Den',
          stock: 5,
          price: item.price + 8000,
        ),
        ProductVariant(
          size: 'L',
          color: 'Xanh Navy',
          stock: 6,
          price: item.price + 15000,
        ),
        ProductVariant(
          size: 'L',
          color: 'Den',
          stock: 4,
          price: item.price + 13000,
        ),
        ProductVariant(
          size: 'XL',
          color: 'Den',
          stock: 2,
          price: item.price + 20000,
        ),
      ],
      colorImages: {
        'Do': [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1200',
          'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=1200',
        ],
        'Xanh Navy': [
          'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=1200',
          'https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=1200',
        ],
        'Den': [
          'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?w=1200',
          'https://images.unsplash.com/photo-1528701800489-20be9c5f88df?w=1200',
        ],
        'Trang': [
          'https://images.unsplash.com/photo-1605348532760-6753d2c43329?w=1200',
        ],
      },
      reviews: [
        ProductReview(
          id: 'rv-1',
          userName: 'Minh Anh',
          rating: 5,
          comment: 'Form dep, mang em chan.',
          imageUrl:
              'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=800',
          createdAt: DateTime(2026, 3, 1),
        ),
        ProductReview(
          id: 'rv-2',
          userName: 'Tuan K',
          rating: 4,
          comment: 'Mau giong hinh, giao nhanh.',
          createdAt: DateTime(2026, 2, 25),
        ),
      ],
      vouchers: const [
        ProductVoucher(
          id: 'vc-1',
          title: 'Giam 20.000d',
          discountAmount: 20000,
          minOrderValue: 120000,
        ),
        ProductVoucher(
          id: 'vc-2',
          title: 'Freeship 15.000d',
          discountAmount: 15000,
          minOrderValue: 99000,
          isFreeship: true,
        ),
      ],
      relatedProducts: [
        RelatedProduct(
          id: '${item.id}-r1',
          name: 'Giay the thao co thap basic',
          imageUrl:
              'https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=700',
          price: item.price * 0.92,
        ),
        RelatedProduct(
          id: '${item.id}-r2',
          name: 'Giay chay bo phan quang',
          imageUrl:
              'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=700',
          price: item.price * 1.08,
        ),
      ],
    );
    notifyListeners();
  }

  void clearSelection() {
    _selectedProduct = null;
    notifyListeners();
  }
}

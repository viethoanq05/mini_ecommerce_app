import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/cart_controller.dart';
import 'screens/product_detail_screen.dart';
import 'services/product_service.dart';
import 'widgets/product_card.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Detail Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEE4D2D)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = ProductService.products;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEE4D2D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sản phẩm nổi bật',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Consumer<CartController>(
            builder: (_, cart, child) => Stack(
              alignment: Alignment.center,
              children: [
                child!,
                if (cart.cartCount > 0)
                  Positioned(
                    top: 8,
                    right: 6,
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${cart.cartCount}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 12.0;
          const padding = 12.0;
          // 2 columns on phones, 3 on tablets/web (width ≥ 600).
          final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
          final itemWidth =
              (constraints.maxWidth -
                  padding * 2 -
                  spacing * (crossAxisCount - 1)) /
              crossAxisCount;
          // Fixed card height = image area + info area, so text never overflows.
          final mainAxisExtent = itemWidth / 1.1 + 128;

          return GridView.builder(
            padding: const EdgeInsets.all(padding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: mainAxisExtent,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) => ProductCard(
              product: products[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(
                    product: products[index],
                    allProducts: products,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

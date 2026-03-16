import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/cart_provider.dart';
import 'controllers/product_detail_controller.dart';
import 'providers/checkout_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/home_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(const MiniEcommerceApp());
}

class MiniEcommerceApp extends StatelessWidget {
  const MiniEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => ProductDetailController()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()..load()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mini Ecommerce',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}

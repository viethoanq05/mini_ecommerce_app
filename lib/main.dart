import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/home_screen.dart';
import 'theme/theme.dart';
import 'controllers/currency_controller.dart';
import 'controllers/user_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyController()),
        ChangeNotifierProvider(create: (_) => UserController()),
      ],
      child: const MiniEcommerceApp(),
    ),
  );
}

class MiniEcommerceApp extends StatelessWidget {
  const MiniEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
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

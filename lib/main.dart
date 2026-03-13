import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(const MiniEcommerceApp());
}

class MiniEcommerceApp extends StatelessWidget {
  const MiniEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Ecommerce',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_item.dart';
import '../models/category_item.dart';

class ProductService {
  final String _baseUrl = 'https://fakestoreapi.com/products';

  Future<List<ProductItem>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProductItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<ProductItem>> getByTag(String tag) async {
    final response = await http.get(Uri.parse('$_baseUrl/category/$tag'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProductItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products by tag');
    }
  }

  Future<ProductItem> getById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return ProductItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product with id $id');
    }
  }

  Future<List<CategoryItem>> getAllCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/categories'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((categoryName) {
        final String name = categoryName.toString();
        return CategoryItem(
          title: name,
          icon: _getCategoryIcon(name),
          color: _getCategoryColor(name),
        );
      }).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<ProductItem>> getByPriceRange(double min, double max) async {
    final allProducts = await getAll();
    return allProducts.where((product) => product.price >= min && product.price <= max).toList();
  }

  double calculateTotal(List<ProductItem> items) {
    return items.fold(0.0, (total, item) => total + item.price);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices_rounded;
      case 'jewelery':
        return Icons.diamond_rounded;
      case "men's clothing":
        return Icons.man_rounded;
      case "women's clothing":
        return Icons.woman_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return const Color(0xFF4C6EF5);
      case 'jewelery':
        return const Color(0xFFFAB005);
      case "men's clothing":
        return const Color(0xFF15AABF);
      case "women's clothing":
        return const Color(0xFFE64980);
      default:
        return const Color(0xFF868E96);
    }
  }
}

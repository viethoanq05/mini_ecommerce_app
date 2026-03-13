import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_item.dart';

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
}

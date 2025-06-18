import '../models/product.dart';
import 'package:dio/dio.dart';

class ProductRepository {
  ProductRepository({Dio? dio}) : _dio = dio ?? Dio();

  static const _baseUrl = 'https://fakestoreapi.com';

  final Dio _dio;

  Future<List<Product>> fetchProducts(
      {String? query, int? page, int limit = 20}) async {
    final response = await _dio.get('$_baseUrl/products', queryParameters: {
      if (page != null) 'limit': limit, // fakestoreapi supports limit
      if (page != null) 'sort': 'desc',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    final List<dynamic> data = response.data as List<dynamic>;
    var products =
        data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();

    if (query == null || query.isEmpty) return products;
    final lower = query.toLowerCase();
    products = products
        .where((p) =>
            p.title.toLowerCase().contains(lower) ||
            p.description.toLowerCase().contains(lower))
        .toList();
    return products;
  }

  void dispose() => _dio.close(force: true);
}

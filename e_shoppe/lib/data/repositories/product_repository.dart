import 'package:e_shoppe/data/models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:e_shoppe/services/api_client.dart';

class ProductRepository {
  ProductRepository(this._api);

  final ApiClient _api;

  Future<List<Product>> fetchProducts({String? query}) async {
    final List<dynamic> json = await _api.get('/products') as List<dynamic>;
    var products =
        json.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    if (query == null || query.isEmpty) return products;
    final lower = query.toLowerCase();
    return products
        .where((p) =>
            p.title.toLowerCase().contains(lower) ||
            p.description.toLowerCase().contains(lower))
        .toList();
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final api = ref.read(apiProvider);
  return ProductRepository(api);
});

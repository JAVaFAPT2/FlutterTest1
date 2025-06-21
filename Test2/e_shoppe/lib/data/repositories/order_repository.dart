import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_client.dart';
import '../models/cart_item.dart';
import '../models/user.dart';

class OrderRepository {
  OrderRepository(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> createOrder(
      User customer, List<CartItem> items) {
    final body = {
      'customer': {
        'id': customer.id,
        'name': customer.name,
        'email': customer.email,
      },
      'items': items
          .map((e) => {
                'productId': e.product.id.toString(),
                'quantity': e.quantity,
              })
          .toList(),
    };
    return _api.post('/orders', body).then((e) => e as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> listOrders() async {
    final List<dynamic> json = await _api.get('/orders') as List<dynamic>;
    return json.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getOrder(String id) async {
    return _api.get('/orders/$id').then((e) => e as Map<String, dynamic>);
  }

  Future<void> updateStatus(String id, String status) async {
    await _api.patch('/orders/$id/status', {'status': status});
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final api = ref.read(apiProvider);
  return OrderRepository(api);
});

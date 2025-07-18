import 'dart:convert';

import 'package:shelf/shelf.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../services/logger.dart';

class Handlers {
  final ProductRepository productRepo;
  final OrderRepository orderRepo;
  Handlers(Object repo)
      : productRepo = repo as ProductRepository,
        orderRepo = repo as OrderRepository;

  // GET /products
  Future<Response> getProducts(Request req) async {
    final products = await productRepo.getAll();
    log.fine('GET /products -> ${products.length} items');
    return Response.ok(
      jsonEncode(products.map((e) => e.toJson()).toList()),
      headers: {'content-type': 'application/json'},
    );
  }

  // POST /orders
  Future<Response> createOrder(Request req) async {
    final data = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final customer = Customer.fromJson(
      data['customer'] as Map<String, dynamic>,
    );
    final itemsJson = data['items'] as List<dynamic>;
    final items = <OrderItem>[];
    for (final itemJson in itemsJson) {
      final productIdStr = itemJson['productId'].toString();
      final productId = int.tryParse(productIdStr);
      if (productId == null) {
        return Response(400, body: 'Invalid productId');
      }
      final qty = itemJson['quantity'] as int;
      final product = await productRepo.getById(productId);
      if (product == null) {
        return Response.notFound('Product $productId not found');
      }
      items.add(OrderItem(product: product, quantity: qty));
    }
    final order = await orderRepo.createOrder(customer, items);
    log.info(
        'Created order ${order.id} with ${items.length} items for customer ${customer.id}');
    return Response(
      201,
      body: jsonEncode(order.toJson()),
      headers: {'content-type': 'application/json'},
    );
  }

  // GET /orders/<id>
  Future<Response> getOrderById(Request req, String id) async {
    final order = await orderRepo.getOrderById(id);
    if (order == null) return Response.notFound('Order not found');
    log.fine('GET /orders/$id');
    return Response.ok(
      jsonEncode(order.toJson()),
      headers: {'content-type': 'application/json'},
    );
  }

  // GET /orders
  Future<Response> listOrders(Request req) async {
    final orders = await orderRepo.listOrders();
    log.fine('GET /orders -> ${orders.length} orders');
    return Response.ok(
      jsonEncode(orders.map((e) => e.toJson()).toList()),
      headers: {'content-type': 'application/json'},
    );
  }

  // PATCH /orders/<id>/status
  Future<Response> updateOrderStatus(Request req, String id) async {
    final data = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final statusStr = data['status'] as String?;
    if (statusStr == null) {
      return Response(400, body: 'Missing status');
    }
    try {
      final status = OrderStatus.values.byName(statusStr);
      await orderRepo.updateStatus(id, status);
      log.info('Order $id status updated to ${status.name}');
      return Response.ok('updated');
    } catch (_) {
      log.warning('Invalid status "$statusStr" for order $id');
      return Response(400, body: 'Invalid status');
    }
  }
}

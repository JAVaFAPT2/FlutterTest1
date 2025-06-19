import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:order_server/presentation/cors_middleware.dart';
import 'package:order_server/infrastructure/in_memory_repositories.dart';
import 'package:order_server/application/handlers.dart';
import 'package:order_server/presentation/auth_middleware.dart';

Future<void> main() async {
  // In-memory infrastructure
  final store = InMemoryStore();
  final handlers = Handlers(store);

  final router = Router()
    ..get('/products', handlers.getProducts)
    ..post('/orders', handlers.createOrder)
    ..get('/orders', handlers.listOrders)
    ..get('/orders/<id>', handlers.getOrderById)
    ..patch('/orders/<id>/status', handlers.updateOrderStatus);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(cors())
      .addMiddleware(jwtMiddleware())
      .addHandler(router);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('🚀  Order server running on port ${server.port}');
}

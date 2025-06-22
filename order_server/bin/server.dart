import 'dart:io';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:order_server/presentation/cors_middleware.dart';
import 'package:order_server/infrastructure/in_memory_repositories.dart';
import 'package:order_server/application/handlers.dart';
import 'package:order_server/presentation/auth_middleware.dart';
import 'package:order_server/services/logger.dart';
import 'package:order_server/infrastructure/postgres_repositories.dart';

Future<void> main() async {
  // Init logging
  initLogging();

  // Choose infrastructure: Postgres when PG_HOST env var provided, otherwise in-memory.
  Handlers handlers;
  if (Platform.environment.containsKey('PG_HOST')) {
    try {
      final pg = await PostgresStore.connectFromEnv();
      log.info('✅ Connected to Postgres database');
      handlers = Handlers(pg);
      if (handlers.productRepo is PostgresStore) {
        await _autoSeedProducts(handlers.productRepo as PostgresStore,
            minCount: 100);
      }
    } catch (e, st) {
      log.warning(
          '⚠️  Failed to connect to Postgres – using in-memory store. Error: $e');
      log.fine(st);
      handlers = Handlers(InMemoryStore());
    }
  } else {
    log.info('ℹ️  PG_HOST not set – using in-memory store');
    handlers = Handlers(InMemoryStore());
  }

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
  log.info('🚀  Order server running on port ${server.port}');
}

Future<void> _autoSeedProducts(PostgresStore store,
    {int minCount = 100}) async {
  final conn = store.conn;
  // Ensure table exists
  await conn.execute('''
    CREATE TABLE IF NOT EXISTS products (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      price DOUBLE PRECISION NOT NULL,
      image TEXT
    );
  ''');
  final existing =
      (await conn.query('SELECT COUNT(*) FROM products')).first[0] as int;
  if (existing >= minCount) return;
  final rand = Random();
  final values = <String>[];
  for (int i = existing + 1; i <= minCount; i++) {
    final name = 'Sample Product $i';
    final desc = 'Auto-generated product #$i';
    final price = (rand.nextInt(900) + 100) * 1000; // 100k-1m
    values.add(
        "('${name.replaceAll("'", "''")}','${desc.replaceAll("'", "''")}',$price)");
  }
  await conn.execute(
      'INSERT INTO products(name, description, price) VALUES ${values.join(',')}');
  log.info('Seeded ${minCount - existing} products (total $minCount).');
}

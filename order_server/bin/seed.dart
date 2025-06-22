import 'dart:math';

import 'package:logging/logging.dart';
import 'package:order_server/infrastructure/postgres_repositories.dart';
import 'package:order_server/services/logger.dart';
import 'package:postgres/postgres.dart';

/// Seeds the Postgres database with at least [count] products.
Future<void> main(List<String> args) async {
  final count = args.isNotEmpty ? int.parse(args.first) : 100;

  initLogging(level: Level.INFO);
  final store = await PostgresStore.connectFromEnv();
  final conn = store.conn; // expose via getter we add.

  await _ensureProducts(conn);
  final existing =
      (await conn.query('SELECT COUNT(*) FROM products')).first[0] as int;
  if (existing >= count) {
    log.info('Database already has $existing products – no seeding needed.');
    await conn.close();
    return;
  }

  final rand = Random();
  final batch =
      StringBuffer('INSERT INTO products(name, description, price) VALUES ');
  final values = <String>[];
  for (int i = existing + 1; i <= count; i++) {
    final name = 'Test Product $i';
    final desc = 'Auto-generated product #$i';
    final price = (rand.nextInt(900) + 100) * 1000; // 100k – 1m
    values.add(
        "('${name.replaceAll("'", "''")}', '${desc.replaceAll("'", "''")}', $price)");
  }
  batch.write(values.join(','));
  await conn.execute(batch.toString());
  log.info('Seeded ${count - existing} products (total $count).');
  await conn.close();
}

Future<void> _ensureProducts(PostgreSQLConnection conn) async {
  await conn.execute('''
    CREATE TABLE IF NOT EXISTS products (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      price DOUBLE PRECISION NOT NULL,
      image TEXT
    );
  ''');
}

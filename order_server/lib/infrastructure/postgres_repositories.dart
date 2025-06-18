import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities.dart';
import '../domain/repositories.dart';

class PostgresStore implements ProductRepository, OrderRepository {
  final PostgreSQLConnection _conn;
  final _uuid = const Uuid();

  PostgresStore(this._conn);

  static Future<PostgresStore> connectFromEnv() async {
    final host = const String.fromEnvironment(
      'PG_HOST',
      defaultValue: 'localhost',
    );
    final port = int.parse(
      const String.fromEnvironment('PG_PORT', defaultValue: '5432'),
    );
    final user = const String.fromEnvironment(
      'PG_USER',
      defaultValue: 'postgres',
    );
    final pass = const String.fromEnvironment(
      'PG_PASS',
      defaultValue: 'postgres',
    );
    final db = const String.fromEnvironment('PG_DB', defaultValue: 'orders');
    final conn =
        PostgreSQLConnection(host, port, db, username: user, password: pass);
    await conn.open();
    return PostgresStore(conn);
  }

  // ProductRepository
  @override
  Future<List<Product>> getAll() async {
    final rows = await _conn.mappedResultsQuery('SELECT * FROM products');
    return rows.map((row) {
      final r = row['products']!;
      return Product(
        id: r['id'].toString(),
        name: r['name'] as String,
        description: r['description'] as String,
        price: (r['price'] as num).toDouble(),
      );
    }).toList();
  }

  @override
  Future<Product?> getById(String id) async {
    final rows = await _conn.mappedResultsQuery(
        'SELECT * FROM products WHERE id=@id',
        substitutionValues: {'id': id});
    if (rows.isEmpty) return null;
    final r = rows.first['products']!;
    return Product(
      id: r['id'].toString(),
      name: r['name'] as String,
      description: r['description'] as String,
      price: (r['price'] as num).toDouble(),
    );
  }

  // OrderRepository
  @override
  Future<Order> createOrder(Customer customer, List<OrderItem> items) async {
    final orderId = _uuid.v4();
    await _conn.transaction((ctx) async {
      await ctx.execute(
          'INSERT INTO orders(id, customer_id, created_at, status) VALUES (@id,@cid,now(),@st)',
          substitutionValues: {
            'id': orderId,
            'cid': customer.id,
            'st': OrderStatus.pending.name
          });
      for (final item in items) {
        await ctx.execute(
            'INSERT INTO order_items(order_id, product_id, quantity) VALUES (@oid,@pid,@qty)',
            substitutionValues: {
              'oid': orderId,
              'pid': item.product.id,
              'qty': item.quantity
            });
      }
    });
    return Order(id: orderId, customer: customer, items: items);
  }

  @override
  Future<Order?> getOrderById(String id) async {
    final orderRows = await _conn.mappedResultsQuery(
        'SELECT * FROM orders WHERE id=@id',
        substitutionValues: {'id': id});
    if (orderRows.isEmpty) return null;
    // Fetch items
    final itemRows = await _conn.mappedResultsQuery(
        'SELECT p.*, oi.quantity FROM order_items oi JOIN products p ON p.id=oi.product_id WHERE oi.order_id=@id',
        substitutionValues: {'id': id});
    final items = itemRows.map((row) {
      final p = row['p'] ?? row['products']!;
      final qty = row['oi']?['quantity'] ?? row['order_items']!['quantity'];
      final product = Product(
        id: p['id'].toString(),
        name: p['name'] as String,
        description: p['description'] as String,
        price: (p['price'] as num).toDouble(),
      );
      return OrderItem(product: product, quantity: qty as int);
    }).toList();
    final customer = Customer(id: 'unknown', name: 'Unknown', email: '');
    return Order(
      id: id,
      customer: customer,
      items: items,
      status: OrderStatus.pending,
    );
  }

  @override
  Future<List<Order>> listOrders() async {
    final rows = await _conn.mappedResultsQuery('SELECT * FROM orders');
    final List<Order> orders = [];
    for (final row in rows) {
      final o = row['orders']!;
      final orderId = o['id'].toString();
      final itemsRows = await _conn.mappedResultsQuery(
        'SELECT p.*, oi.quantity FROM order_items oi JOIN products p ON p.id=oi.product_id WHERE oi.order_id=@id',
        substitutionValues: {'id': orderId},
      );
      final items = itemsRows.map((r) {
        final p = r['p'] ?? r['products']!;
        final qty = r['oi']?['quantity'] ?? r['order_items']!['quantity'];
        final product = Product(
          id: p['id'].toString(),
          name: p['name'] as String,
          description: p['description'] as String,
          price: (p['price'] as num).toDouble(),
        );
        return OrderItem(product: product, quantity: qty as int);
      }).toList();
      orders.add(
        Order(
          id: orderId,
          customer: Customer(id: 'unknown', name: 'Unknown', email: ''),
          items: items,
          status: OrderStatus.values.byName(
            o['status'] as String? ?? 'pending',
          ),
        ),
      );
    }
    return orders;
  }

  @override
  Future<void> updateStatus(String id, OrderStatus status) async {
    await _conn.execute('UPDATE orders SET status=@s WHERE id=@id',
        substitutionValues: {'s': status.name, 'id': id});
  }
}

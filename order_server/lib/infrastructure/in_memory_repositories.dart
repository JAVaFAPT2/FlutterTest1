import 'package:uuid/uuid.dart';

import '../domain/entities.dart';
import '../domain/repositories.dart';

class InMemoryStore implements ProductRepository, OrderRepository {
  final _uuid = const Uuid();
  int _nextProductId = 1;
  final Map<int, Product> _products = {};
  final Map<String, Order> _orders = {};

  InMemoryStore() {
    // seed few products
    _addProduct('Plant', 5500000);
    _addProduct('Watch', 450000);
    _addProduct('Bag', 1200000);

    // Extra products for more realistic catalog
    _addProduct('Laptop', 18500000);
    _addProduct('Smartphone', 12500000);
    _addProduct('Headphones', 2500000);
    _addProduct('Camera', 21500000);
    _addProduct('Sneakers', 1800000);
    _addProduct('T-Shirt', 350000);
  }

  void _addProduct(String name, double price) {
    final id = _nextProductId++;
    _products[id] = Product(
      id: id,
      name: name,
      description: name,
      price: price,
      imageUrl: 'https://picsum.photos/seed/$id/200/200',
    );
  }

  // ProductRepository
  @override
  Future<List<Product>> getAll() async => _products.values.toList();

  @override
  Future<Product?> getById(int id) async => _products[id];

  // OrderRepository
  @override
  Future<Order> createOrder(Customer customer, List<OrderItem> items) async {
    final id = _uuid.v4();
    final order = Order(id: id, customer: customer, items: items);
    _orders[id] = order;
    return order;
  }

  @override
  Future<Order?> getOrderById(String id) async => _orders[id];

  @override
  Future<List<Order>> listOrders() async => _orders.values.toList();

  @override
  Future<void> updateStatus(String id, OrderStatus status) async {
    final order = _orders[id];
    if (order != null) {
      order.status = status;
    }
  }
}

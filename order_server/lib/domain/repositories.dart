import 'entities.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<Product?> getById(String id);
}

abstract class OrderRepository {
  Future<Order> createOrder(Customer customer, List<OrderItem> items);
  Future<Order?> getOrderById(String id);
  Future<List<Order>> listOrders();
  Future<void> updateStatus(String id, OrderStatus status);
}

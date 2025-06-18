import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
  );
}

class Customer {
  final String id;
  final String name;
  final String email;

  Customer({required this.id, required this.name, required this.email});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
  );
}

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'subtotal': subtotal,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    product: Product.fromJson(json['product'] as Map<String, dynamic>),
    quantity: json['quantity'] as int,
  );
}

enum OrderStatus { pending, confirmed, shipped, completed, cancelled }

class Order {
  final String id;
  final Customer customer;
  final List<OrderItem> items;
  final DateTime createdAt;
  OrderStatus status;

  Order({
    required this.id,
    required this.customer,
    required this.items,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get total => items.fold(0, (prev, e) => prev + e.subtotal);

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer': customer.toJson(),
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
    items: (json['items'] as List<dynamic>)
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    status: OrderStatus.values.byName(json['status'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/data/models/cart_item.dart';
import 'package:e_shoppe/data/models/user.dart';

class OrderDraft {
  final User? customer;
  final List<CartItem> items;
  final String? note;
  final String? country;
  final String? city;
  final String? address;
  final String? paymentMethod;
  final double discount;

  // --- Computed amounts ---
  double get subtotal => items.fold(0, (prev, e) => prev + e.subtotal);
  static const double vatRate = 0.1; // 10%
  static const double shippingFlat = 50000; // Vnd

  double get vat => subtotal * vatRate;
  double get shippingFee => items.isEmpty ? 0 : shippingFlat;
  double get total => subtotal - discount + vat + shippingFee;

  const OrderDraft({
    this.customer,
    this.items = const [],
    this.note,
    this.country,
    this.city,
    this.address,
    this.paymentMethod,
    this.discount = 0,
  });

  OrderDraft copyWith({
    User? customer,
    List<CartItem>? items,
    String? note,
    String? country,
    String? city,
    String? address,
    String? paymentMethod,
    double? discount,
  }) {
    return OrderDraft(
      customer: customer ?? this.customer,
      items: items ?? this.items,
      note: note ?? this.note,
      country: country ?? this.country,
      city: city ?? this.city,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      discount: discount ?? this.discount,
    );
  }
}

class OrderDraftNotifier extends StateNotifier<OrderDraft> {
  OrderDraftNotifier() : super(const OrderDraft());

  void setCustomer(User customer) {
    state = state.copyWith(customer: customer);
  }

  void addItem(CartItem item) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.product.id == item.product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(item);
    }
    state = state.copyWith(items: items);
  }

  void updateItem(CartItem item) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.product.id == item.product.id);
    if (index >= 0) {
      items[index] = item;
      state = state.copyWith(items: items);
    }
  }

  void removeItem(String productId) {
    state = state.copyWith(
        items: state.items.where((e) => e.product.id != productId).toList());
  }

  void clear() {
    state = const OrderDraft();
  }
}

final orderDraftProvider =
    StateNotifierProvider<OrderDraftNotifier, OrderDraft>((ref) {
  return OrderDraftNotifier();
});

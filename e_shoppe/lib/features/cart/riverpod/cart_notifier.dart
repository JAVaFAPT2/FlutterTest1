import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:e_shoppe/data/models/cart_item.dart';
import 'package:e_shoppe/data/models/product.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []);

  void add(Product p) {
    final items = [...state];
    final idx = items.indexWhere((e) => e.product.id == p.id);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(CartItem(product: p, quantity: 1));
    }
    state = items;
  }

  void remove(int id) {
    state = state.where((e) => e.product.id != id).toList();
  }

  void changeQty(int id, int delta) {
    final items = [...state];
    final idx = items.indexWhere((e) => e.product.id == id);
    if (idx >= 0) {
      final newQty = (items[idx].quantity + delta).clamp(1, 100);
      items[idx] = items[idx].copyWith(quantity: newQty);
      state = items;
    }
  }

  double get subtotal => state.fold(0, (s, e) => s + e.subtotal);
  double get discount => state.fold(0, (s, e) => s + e.discountValue);
  double get total => subtotal - discount;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
    (ref) => CartNotifier());

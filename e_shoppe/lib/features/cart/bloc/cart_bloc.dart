import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/cart_item.dart';
import '../../../data/models/product.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartItemAdded>(_onAdded);
    on<CartItemRemoved>(_onRemoved);
    on<CartItemQuantityChanged>(_onQtyChanged);
    on<CartCleared>(_onCleared);
    on<CartItemDiscountChanged>(_onDiscountChanged);
  }

  void _onAdded(CartItemAdded event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.product.id == event.product.id);
    if (index >= 0) {
      final existing = items[index];
      items[index] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      items.add(CartItem(product: event.product, quantity: 1));
    }
    emit(state.copyWith(items: items));
  }

  void _onRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    final items =
        state.items.where((e) => e.product.id != event.productId).toList();
    emit(state.copyWith(items: items));
  }

  void _onQtyChanged(CartItemQuantityChanged event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((e) => e.product.id == event.productId);
    if (idx >= 0) {
      final newQty = items[idx].quantity + event.delta;
      if (newQty <= 0) {
        // remove the item entirely when quantity drops to 0 or below
        items.removeAt(idx);
      } else {
        final updatedQty = newQty.clamp(1, 100);
        items[idx] = items[idx].copyWith(quantity: updatedQty);
      }
      emit(state.copyWith(items: items));
    }
  }

  void _onCleared(CartCleared event, Emitter<CartState> emit) {
    emit(const CartState());
  }

  void _onDiscountChanged(
      CartItemDiscountChanged event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((e) => e.product.id == event.productId);
    if (idx >= 0) {
      final subtotal = items[idx].subtotal;
      final discount = event.discount.clamp(0, subtotal).toDouble();
      items[idx] = items[idx].copyWith(discountValue: discount);
      emit(state.copyWith(items: items));
    }
  }
}

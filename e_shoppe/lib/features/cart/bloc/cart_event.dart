part of 'cart_bloc.dart';

sealed class CartEvent {
  const CartEvent();
}

class CartItemAdded extends CartEvent {
  const CartItemAdded(this.product);
  final Product product;
}

class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.productId);
  final int productId;
}

class CartItemQuantityChanged extends CartEvent {
  const CartItemQuantityChanged({required this.productId, required this.delta});
  final int productId;
  final int delta; // +1 or -1
}

class CartCleared extends CartEvent {
  const CartCleared();
}

class CartItemDiscountChanged extends CartEvent {
  const CartItemDiscountChanged(
      {required this.productId, required this.discount});
  final int productId;
  final double discount;
}

import 'package:equatable/equatable.dart';

import 'package:e_shoppe/data/models/product.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.quantity,
    this.discountValue = 0,
  });

  final Product product;
  final int quantity;
  final double discountValue; // absolute amount

  double get subtotal => product.price * quantity;
  double get total => subtotal - discountValue;

  CartItem copyWith({int? quantity, double? discountValue}) => CartItem(
        product: product,
        quantity: quantity ?? this.quantity,
        discountValue: discountValue ?? this.discountValue,
      );

  @override
  List<Object?> get props => [product, quantity, discountValue];
}

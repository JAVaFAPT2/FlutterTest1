part of 'cart_bloc.dart';

class CartState extends Equatable {
  const CartState({this.items = const []});

  final List<CartItem> items;

  double get total => items.fold(0, (sum, item) => sum + item.total);
  double get totalDiscount => items.fold(0, (s, e) => s + e.discountValue);

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);

  @override
  List<Object?> get props => [items];
}

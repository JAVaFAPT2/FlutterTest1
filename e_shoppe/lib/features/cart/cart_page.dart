import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart_item.dart';
import '../cart/bloc/cart_bloc.dart';
import '../checkout/checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }
          return ListView.separated(
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _CartListTile(item: item);
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                    child: Text('Total: \$${state.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))),
                ElevatedButton(
                  onPressed: state.items.isNotEmpty
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CheckoutPage()),
                          );
                        }
                      : null,
                  child: const Text('Checkout'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CartListTile extends StatelessWidget {
  const _CartListTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(item.product.imageUrl,
          width: 56, height: 56, fit: BoxFit.cover),
      title: Text(item.product.title,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('Subtotal: \$${item.subtotal.toStringAsFixed(2)}'),
      trailing: SizedBox(
        width: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                context.read<CartBloc>().add(CartItemQuantityChanged(
                    productId: item.product.id, delta: -1));
              },
            ),
            Text(item.quantity.toString()),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                context.read<CartBloc>().add(CartItemQuantityChanged(
                    productId: item.product.id, delta: 1));
              },
            ),
          ],
        ),
      ),
    );
  }
}

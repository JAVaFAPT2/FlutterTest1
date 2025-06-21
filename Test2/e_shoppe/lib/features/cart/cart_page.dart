import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart_item.dart';
import '../cart/bloc/cart_bloc.dart';
import '../../shared/utils/formatter.dart';
import '../../shared/spacing.dart';
import '../../theme/app_theme.dart';
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
            color: AppColors.white,
            child: Row(
              children: [
                Expanded(
                    child: Text('Tổng: ${formatCurrency(state.total)}',
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
      leading: item.product.imageUrl.isNotEmpty
          ? Image.network(item.product.imageUrl,
              width: 56, height: 56, fit: BoxFit.cover)
          : Container(
              width: 56,
              height: 56,
              color: AppColors.lightGray,
              child: const Icon(Icons.image_not_supported),
            ),
      title: Text(item.product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('Tạm tính: ${formatCurrency(item.subtotal)}'),
      trailing: SizedBox(
        width: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon:
                  const Icon(Icons.remove_circle_outline, color: AppColors.red),
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

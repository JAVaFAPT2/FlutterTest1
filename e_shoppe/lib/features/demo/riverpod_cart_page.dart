import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import 'package:e_shoppe/data/models/product.dart';
import 'package:e_shoppe/features/cart/riverpod/cart_notifier.dart';

class RiverpodCartPage extends ConsumerWidget {
  const RiverpodCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Cart Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  leading: Image.network(item.product.imageUrl, width: 48, height: 48, fit: BoxFit.cover),
                  title: Text(item.product.title),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => ref.read(cartProvider.notifier).changeQty(item.product.id, -1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => ref.read(cartProvider.notifier).changeQty(item.product.id, 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => ref.read(cartProvider.notifier).remove(item.product.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Subtotal: ₱${ref.read(cartProvider.notifier).subtotal.toStringAsFixed(2)}'),
                Text('Discount: ₱${ref.read(cartProvider.notifier).discount.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text(
                  'Total: ₱${ref.read(cartProvider.notifier).total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_shopping_cart),
        onPressed: () {
          final random = Random();
          final sample = Product(
            id: random.nextInt(100000),
            title: 'Sample Item ${random.nextInt(100)}',
            description: 'Generated demo product',
            imageUrl: 'https://picsum.photos/seed/${random.nextInt(1000)}/200/200',
            price: random.nextInt(500).toDouble() + 0.99,
          );
          ref.read(cartProvider.notifier).add(sample);
        },
      ),
    );
  }
} 
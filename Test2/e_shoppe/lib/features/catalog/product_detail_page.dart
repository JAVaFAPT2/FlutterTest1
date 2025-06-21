import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product.dart';
import '../cart/bloc/cart_bloc.dart';
import '../cart/cart_page.dart';
import '../../shared/utils/formatter.dart';
import '../../theme/app_theme.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Text(product.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(formatCurrency(product.price),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.green)),
            const SizedBox(height: 16),
            Text(product.description),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            context.read<CartBloc>().add(CartItemAdded(product));
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CartPage()));
          },
          child: const Text('Add to Cart'),
        ),
      ),
    );
  }
}

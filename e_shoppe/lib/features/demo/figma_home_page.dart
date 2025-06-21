import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../theme/figma_theme.dart';

final _productsProvider = FutureProvider<List<Product>>((ref) {
  final repo = ref.read(productRepositoryProvider);
  return repo.fetchProducts();
});

/// First v2 screen generated from Figma (node 0:1).
class FigmaHomePage extends ConsumerWidget {
  const FigmaHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(_productsProvider);
    return Theme(
      // Ensure we use the new figma theme within this subtree.
      data: figmaLightTheme(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Catalog')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: asyncProducts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
              child: Text('Error: $err', style: FigmaTextStyles.subhead),
            ),
            data: (products) => GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) => _ProductCard(product: products[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: FigmaColors.gray.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: FigmaColors.gray.withOpacity(0.2),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, style: FigmaTextStyles.subhead),
                  const SizedBox(height: 4),
                  Text('${product.price.toStringAsFixed(0)} đ',
                      style: FigmaTextStyles.body
                          .copyWith(color: FigmaColors.accent)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

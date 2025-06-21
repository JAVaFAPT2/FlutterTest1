import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_shoppe/features/catalog/product_detail_page.dart';

import '../../data/models/product.dart';
import 'riverpod/search_notifier.dart';
import '../../shared/widgets/blue_header.dart';
import '../../shared/widgets/search_bar.dart';
import '../../shared/responsive.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      body: Column(
        children: [
          // Blue header bar
          const BlueHeader(
            title: 'Chọn sản phẩm tạo đơn',
          ),
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBarField(
              hint: 'Nhập mã sản phẩm/ tên sản phẩm',
              onChanged: (q) =>
                  ref.read(searchProvider.notifier).onQueryChanged(q),
            ),
          ),
          Expanded(
            child: () {
              switch (state.status) {
                case SearchStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case SearchStatus.failure:
                  return Center(child: Text(state.error ?? 'Error'));
                case SearchStatus.success:
                  return _ProductList(
                    products: state.products,
                    onEndReached: () =>
                        ref.read(searchProvider.notifier).loadMore(),
                  );
                case SearchStatus.initial:
                  return const SizedBox.shrink();
              }
            }(),
          ),
        ],
      ),
    );
  }
}

class _ProductList extends StatefulWidget {
  const _ProductList({required this.products, required this.onEndReached});

  final List<Product> products;
  final VoidCallback onEndReached;

  @override
  State<_ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<_ProductList> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 200) {
          widget.onEndReached();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const Center(child: Text('No products found'));
    }
    final cols = Responsive.gridColumnCount(context);

    // Mobile – use ListView for better readability
    if (cols == 1) {
      return ListView.builder(
        controller: _controller,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final product = widget.products[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product)));
            },
            child: Card(
              elevation: 0.5,
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (c, _) => const SizedBox(
                        width: 80,
                        height: 80,
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2))),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.error_outline),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Tablet/Desktop – keep grid
    return GridView.builder(
      controller: _controller,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        final product = widget.products[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product)),
            );
          },
          child: Card(
            elevation: 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.error_outline),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

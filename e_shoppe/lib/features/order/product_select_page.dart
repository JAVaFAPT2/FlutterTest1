import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/data/models/cart_item.dart';
import 'package:e_shoppe/data/models/product.dart';
import 'package:e_shoppe/data/repositories/product_repository.dart';

import 'package:e_shoppe/features/order/order_app_bar.dart';
import 'package:e_shoppe/features/order/riverpod/order_draft_provider.dart';

class ProductSelectPage extends ConsumerStatefulWidget {
  const ProductSelectPage({super.key});

  @override
  ConsumerState<ProductSelectPage> createState() => _ProductSelectPageState();
}

class _ProductSelectPageState extends ConsumerState<ProductSelectPage> {
  final _searchCtrl = TextEditingController();
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(productRepositoryProvider);
    _future = repo.fetchProducts();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final repo = ref.read(productRepositoryProvider);
    setState(() {
      _future = repo.fetchProducts(query: _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: const OrderAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 20),
                  hintText: 'Nhập mã sản phẩm/ tên sản phẩm',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Center(child: Text('Không tìm thấy sản phẩm'));
                }
                return ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ListTile(
                      leading: p.imageUrl.isNotEmpty
                          ? Image.network(p.imageUrl,
                              width: 56, height: 56, fit: BoxFit.cover)
                          : Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported),
                            ),
                      title: Text(p.title,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${p.price.toStringAsFixed(0)} đ'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () {
                          final item = CartItem(product: p, quantity: 1);
                          ref.read(orderDraftProvider.notifier).addItem(item);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('Đã thêm vào đơn hàng'),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.fromLTRB(16, 0, 16, 80),
                                duration: Duration(seconds: 2),
                              ),
                            );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

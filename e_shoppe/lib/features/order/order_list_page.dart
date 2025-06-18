import 'package:flutter/material.dart';
import 'order_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/data/repositories/order_repository.dart';

class OrderListPage extends ConsumerWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: const OrderAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(6)),
              child: const TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Tìm kiếm',
                    border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Các đơn hàng',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF008000))),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: ref.read(orderRepositoryProvider).listOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final orders = snapshot.data ?? [];
                  if (orders.isEmpty) {
                    return const Center(child: Text('No orders'));
                  }
                  return ListView.separated(
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final o = orders[i];
                      return ListTile(
                        onTap: () => Navigator.of(context)
                            .pushNamed('/order/detail', arguments: o['id']),
                        leading: Text(o['id'] ?? ''),
                        title:
                            Text('SL ${o['items'].length}  |  ${o['total']}đ'),
                        subtitle: Text(o['createdAt']?.substring(0, 10) ?? ''),
                        trailing: Text(o['status'] ?? ''),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CFFF)),
            onPressed: () {
              Navigator.of(context).pushNamed('/order/create');
            },
            child: const Text('Tạo đơn hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _MockOrder {
  final String id;
  final DateTime date;
  final String status;
  final double total;
  final int quantity;
  const _MockOrder(
      {required this.id,
      required this.date,
      required this.status,
      required this.total,
      required this.quantity});
}

import 'package:flutter/material.dart';
import 'order_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/data/repositories/order_repository.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: const OrderAppBar(),
      backgroundColor: const Color(0xFFE0E0E0),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(orderRepositoryProvider).getOrder(orderId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final order = snapshot.data;
          if (order == null) return const Center(child: Text('Not found'));
          final items = (order['items'] as List<dynamic>);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const _SectionHeader('Thông tin đơn hàng'),
              _InfoRow(label: 'Mã đơn:', value: 'DH212384'),
              _InfoRow(label: 'Sản phẩm:', value: '12'),
              _InfoRow(label: 'Ngày lập:', value: '22/05/2023'),
              _InfoRow(
                  label: 'Trạng thái:',
                  value: 'Chưa xác nhận',
                  color: Colors.red),
              const SizedBox(height: 12),
              const _SectionHeader('Sản phẩm'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final it = items[index] as Map<String, dynamic>;
                  final prod = it['product'] as Map<String, dynamic>;
                  return ListTile(
                    leading:
                        Container(width: 56, height: 56, color: Colors.grey),
                    title: Text(prod['name'] ?? ''),
                    subtitle: Text('${prod['price']}'),
                    trailing: Text('${it['quantity']}'),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                child: const Text('In đơn'),
              ),
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: () {},
                child:
                    const Text('Huỷ đơn', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CFFF)),
            onPressed: () {},
            child: const Text('Cập nhật đơn',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF008000))),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _InfoRow({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

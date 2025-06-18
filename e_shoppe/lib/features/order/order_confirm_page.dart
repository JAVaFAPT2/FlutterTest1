import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/features/order/riverpod/order_draft_provider.dart';
import 'order_app_bar.dart';
import 'package:e_shoppe/data/repositories/order_repository.dart';

class OrderConfirmPage extends ConsumerWidget {
  const OrderConfirmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(orderDraftProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: const OrderAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const _SectionHeader(title: 'Thông tin khách hàng'),
          _InfoRow(
              icon: Icons.person_outline,
              text: draft.customer?.name ?? 'Trần Văn Sướng'),
          _InfoRow(
              icon: Icons.call, text: draft.customer?.phone ?? '0984357636'),
          _InfoRow(
              icon: Icons.email_outlined,
              text: draft.customer?.email ?? 'tvsuongit@gmail.com'),
          _InfoRow(
              icon: Icons.location_on_outlined,
              text: draft.address ?? '293/1 Tôn Dẫn quận 4'),
          const SizedBox(height: 12),
          const _SectionHeader(title: 'Nhân viên chốt đơn'),
          _InfoRow(icon: Icons.person_outline, text: 'Trần Văn Sướng'),
          _InfoRow(icon: Icons.call, text: '0984357636'),
          const SizedBox(height: 12),
          const _SectionHeader(title: 'Thông tin sản phẩm'),
          if (draft.items.isNotEmpty)
            Table(
              columnWidths: const {
                0: FixedColumnWidth(56),
                2: IntrinsicColumnWidth(),
              },
              children: [
                ...draft.items.map((e) => TableRow(children: [
                      Image.network(e.product.imageUrl, width: 56, height: 56),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        child: Text(e.product.title,
                            style: const TextStyle(fontSize: 12)),
                      ),
                      Center(child: Text('${e.quantity}')),
                    ])),
              ],
            ),
          if (draft.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Chưa có sản phẩm'),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CFFF)),
            onPressed: () async {
              final repo = ref.read(orderRepositoryProvider);
              final draft = ref.read(orderDraftProvider);
              try {
                // show loading dialog
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()));
                await repo.createOrder(draft.customer!, draft.items);
                ref.read(orderDraftProvider.notifier).clear();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/order/success', ModalRoute.withName('/orders'));
              } catch (e) {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/order/failure');
              }
            },
            child: const Text('Xác nhận',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
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
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF008000), size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

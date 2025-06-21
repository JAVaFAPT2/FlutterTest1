import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/features/order/riverpod/order_draft_provider.dart';
import 'order_app_bar.dart';
import 'package:e_shoppe/data/repositories/order_repository.dart';
import 'package:e_shoppe/data/models/cart_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_shoppe/features/auth/bloc/auth_bloc.dart';
import 'package:e_shoppe/data/models/user.dart';

class OrderConfirmPage extends ConsumerWidget {
  const OrderConfirmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(orderDraftProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const OrderAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const _SectionHeader(title: 'Thông tin khách hàng'),
          _InfoRow(
            icon: Icons.person_outline,
            text: draft.customer?.name ?? draft.customerName ?? '',
          ),
          _InfoRow(
            icon: Icons.call,
            text: draft.phone ?? draft.customer?.phone ?? '',
          ),
          _InfoRow(
            icon: Icons.email_outlined,
            text: draft.customer?.email ?? draft.customerEmail ?? '',
          ),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: draft.address ?? _buildLocation(draft),
          ),
          const SizedBox(height: 12),
          const _SectionHeader(title: 'Nhân viên chốt đơn'),
          Builder(builder: (context) {
            final authState = context.read<AuthBloc>().state;
            final employee = authState.status == AuthStatus.authenticated
                ? authState.user
                : null;
            return Column(
              children: [
                _InfoRow(
                  icon: Icons.person_outline,
                  text: employee?.name ?? '—',
                ),
                _InfoRow(
                  icon: Icons.call,
                  text: employee?.phone ?? '—',
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          const _SectionHeader(title: 'Thông tin sản phẩm'),
          const _ProductTableHeader(),
          if (draft.items.isNotEmpty)
            Column(
              children: [
                for (final item in draft.items) _ProductRow(item: item),
              ],
            )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48,
              width: double.infinity,
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
                    final customer = draft.customer ??
                        User(
                          id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
                          email: draft.customerEmail ?? '',
                          name: draft.customerName ?? '',
                          address: draft.address,
                          phone: draft.phone,
                        );

                    await repo.createOrder(customer, draft.items);
                    // dismiss loading dialog before navigation
                    if (context.mounted) Navigator.of(context).pop();

                    ref.read(orderDraftProvider.notifier).clear();

                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/order/success',
                        ModalRoute.withName('/orders'),
                      );
                    }
                  } catch (e) {
                    // ensure loading dialog is closed
                    if (context.mounted) Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/order/failure');
                  }
                },
                child: const Text('Xác nhận',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 112,
              height: 2,
              decoration: BoxDecoration(
                  color: Color(0xFF595959),
                  borderRadius: BorderRadius.circular(30)),
            ),
          ],
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15753C))),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF008000), size: 18),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

// --- Product table ---

class _ProductTableHeader extends StatelessWidget {
  const _ProductTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: const [
          SizedBox(width: 60, child: Text('Hình', style: _headerStyle)),
          Expanded(child: Text('Tên sản phẩm', style: _headerStyle)),
          SizedBox(
              width: 40, child: Center(child: Text('SL', style: _headerStyle))),
        ],
      ),
    );
  }
}

const TextStyle _headerStyle =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.black);

class _ProductRow extends StatelessWidget {
  final CartItem item;
  const _ProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          item.product.imageUrl.isNotEmpty
              ? Image.network(item.product.imageUrl,
                  width: 60, height: 60, fit: BoxFit.cover)
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
                ),
          const SizedBox(width: 8),
          // Title + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEB6317))),
                const SizedBox(height: 2),
                Text('${item.product.price.toStringAsFixed(0)}đ',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            child: Center(
              child: Text('${item.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper to assemble location string from draft fields when no full address provided.
String _buildLocation(OrderDraft draft) {
  final parts = [
    if (draft.zipCode != null && draft.zipCode!.isNotEmpty) draft.zipCode,
    if (draft.city != null && draft.city!.isNotEmpty) draft.city,
    if (draft.country != null && draft.country!.isNotEmpty) draft.country,
  ];
  return parts.join(', ');
}

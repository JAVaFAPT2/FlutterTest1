import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/data/models/user.dart';
import 'package:e_shoppe/data/models/cart_item.dart';
import 'package:e_shoppe/features/order/riverpod/order_draft_provider.dart';
import 'package:e_shoppe/features/order/customer_search_page.dart';

import 'package:e_shoppe/features/order/order_app_bar.dart';

class OrderCreatePage extends ConsumerStatefulWidget {
  const OrderCreatePage({super.key});

  @override
  ConsumerState<OrderCreatePage> createState() => _OrderCreatePageState();
}

class _OrderCreatePageState extends ConsumerState<OrderCreatePage> {
  @override
  void initState() {
    super.initState();
    // Reset draft immediately so widgets initialise with empty values.
    ref.read(orderDraftProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: const OrderAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _SearchCustomerField(ref: ref),
          const SizedBox(height: 12),
          const _SectionTitle(title: 'Thông tin khách hàng'),
          const _CustomerInfoCard(),
          const SizedBox(height: 12),
          const _ProductListCard(),
          const SizedBox(height: 12),
          const _SummaryCard(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00CFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/order/shipping-info');
            },
            child: const Text(
              'Tiếp tục',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchCustomerField extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _SearchCustomerField({required this.ref});

  @override
  ConsumerState<_SearchCustomerField> createState() =>
      _SearchCustomerFieldState();
}

class _SearchCustomerFieldState extends ConsumerState<_SearchCustomerField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.ref.watch(orderDraftProvider).customer;

    // If a customer is selected, show its name in the field (read-only).
    if (customer != null && _ctrl.text != customer.name) {
      _ctrl.text = customer.name;
    }
    if (customer == null && _ctrl.text.isNotEmpty) {
      // Ensure field resets when customer is cleared/new order started.
      _ctrl.clear();
    }

    return TextField(
      controller: _ctrl,
      readOnly: customer != null, // lock editing once chosen via search
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        hintText: 'Nhập SĐT/ Mã thẻ/ Tên khách hàng',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: customer == null
            ? null
            : IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  widget.ref.read(orderDraftProvider.notifier).clearCustomer();
                  _ctrl.clear();
                },
              ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () async {
        // Only open search if not yet selected.
        if (widget.ref.read(orderDraftProvider).customer == null) {
          final selected = await Navigator.of(context).push<User?>(
            MaterialPageRoute(builder: (_) => const CustomerSearchPage()),
          );
          if (selected != null) {
            widget.ref.read(orderDraftProvider.notifier).setCustomer(selected);
          }
        }
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF008000),
        ),
      ),
    );
  }
}

class _CustomerInfoCard extends ConsumerWidget {
  const _CustomerInfoCard();

  Widget _row(IconData icon, String text) {
    final display = text.isEmpty ? '—' : text;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF008000), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(display, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(orderDraftProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _row(Icons.person_outline, d.customerName ?? ''),
          _row(Icons.call, d.phone ?? ''),
          _row(Icons.email_outlined, d.customerEmail ?? ''),
          _row(Icons.location_on_outlined, d.address ?? ''),
        ],
      ),
    );
  }
}

class _ProductListCard extends ConsumerWidget {
  const _ProductListCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(orderDraftProvider).items;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header with add button
          Container(
            color: const Color(0xFF008000),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách sản phẩm',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/order/select-product');
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm mới', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items list
          for (final item in items) _ProductItemTile(item: item),
        ],
      ),
    );
  }
}

class _ProductItemTile extends ConsumerWidget {
  final CartItem item;
  const _ProductItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void changeQty(int delta) {
      ref
          .read(orderDraftProvider.notifier)
          .changeItemQty(item.product.id, delta);
    }

    void remove() {
      ref.read(orderDraftProvider.notifier).removeItem(item.product.id);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              color: Colors.green.shade300,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${item.product.price.toStringAsFixed(0)}đ',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC0000),
                        ),
                      ),
                      if (item.discountValue > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '${(item.product.price + item.discountValue).toStringAsFixed(0)}đ',
                          style: const TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _QtyButton(
                          icon: Icons.remove, onTap: () => changeQty(-1)),
                      const SizedBox(width: 4),
                      Text(item.quantity.toString()),
                      const SizedBox(width: 4),
                      _QtyButton(icon: Icons.add, onTap: () => changeQty(1)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                // Defer removal until after the tap event is finished to avoid
                // "Cannot hit test a render box with no size" when the tile
                // disappears during the gesture handling.
                Future.microtask(remove);
              },
            )
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // InkWell provides splash + correct hit-test logic even when the
    // child's size changes during the same frame.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(orderDraftProvider);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(
              label: 'Giảm giá:',
              value: '-${draft.discount.toStringAsFixed(0)}đ'),
          const SizedBox(height: 6),
          _SummaryRow(
              label: 'Tạm tính:',
              value: '${draft.subtotal.toStringAsFixed(0)}đ'),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'order_app_bar.dart';
import 'riverpod/order_draft_provider.dart';

class ShippingInfoPage extends ConsumerWidget {
  const ShippingInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(orderDraftProvider);
    final notifier = ref.read(orderDraftProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: const OrderAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _SectionTitle('Thông tin giao hàng'),
          _DropdownField(
            label: 'Quốc gia',
            value: draft.country ?? 'Việt Nam',
            items: const ['Việt Nam'],
            onChanged: (v) =>
                notifier.state = notifier.state.copyWith(country: v),
          ),
          _DropdownField(
            label: 'Tỉnh thành phố',
            value: draft.city ?? 'Tp Hồ Chí Minh',
            items: const ['Tp Hồ Chí Minh', 'Hà Nội'],
            onChanged: (v) => notifier.state = notifier.state.copyWith(city: v),
          ),
          _TextField(
            label: 'Địa chỉ',
            initial: draft.address ?? '',
            onChanged: (v) =>
                notifier.state = notifier.state.copyWith(address: v),
          ),
          _SectionTitle('Khuyến mãi'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.card_giftcard),
                    hintText: 'Mã khuyến mãi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0062FF)),
                child: const Text('Áp dụng'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionTitle('Tổng kết phí'),
          _SummaryRow(
              label: 'VAT', value: '${draft.vat.toStringAsFixed(0)} Vnd'),
          _SummaryRow(
              label: 'Phí ship',
              value: '${draft.shippingFee.toStringAsFixed(0)} Vnd'),
          _SummaryRow(
              label: 'Tiền giảm',
              value: '-${draft.discount.toStringAsFixed(0)} Vnd'),
          const Divider(),
          _SummaryRow(
              label: 'Thành tiền',
              value: '${draft.total.toStringAsFixed(0)} Vnd',
              bold: true),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CFFF)),
            onPressed: () {
              Navigator.of(context).pushNamed('/order/confirm');
            },
            child: const Text('Xác nhận thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF008000)),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownField(
      {required this.label,
      required this.value,
      required this.items,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String initial;
  final ValueChanged<String> onChanged;
  const _TextField(
      {required this.label, required this.initial, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: TextFormField(
        initialValue: initial,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        onChanged: onChanged,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow(
      {required this.label, required this.value, this.bold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'order_app_bar.dart';
import 'riverpod/order_draft_provider.dart';

class ShippingInfoPage extends ConsumerStatefulWidget {
  const ShippingInfoPage({super.key});

  @override
  ConsumerState<ShippingInfoPage> createState() => _ShippingInfoPageState();
}

class _ShippingInfoPageState extends ConsumerState<ShippingInfoPage> {
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _promoCtrl;
  late final TextEditingController _zipCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(orderDraftProvider);
    _addressCtrl = TextEditingController(text: draft.address ?? '');
    _promoCtrl = TextEditingController();
    _phoneCtrl = TextEditingController(text: draft.phone ?? '');
    _zipCtrl = TextEditingController(text: draft.zipCode ?? '');
    _nameCtrl = TextEditingController(text: draft.customerName ?? '');
    _emailCtrl = TextEditingController(text: draft.customerEmail ?? '');
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _promoCtrl.dispose();
    _phoneCtrl.dispose();
    _zipCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(orderDraftProvider);
    final notifier = ref.read(orderDraftProvider.notifier);
    // Keep controller text in sync when provider changes from elsewhere.
    if (_addressCtrl.text != (draft.address ?? '')) {
      _addressCtrl.text = draft.address ?? '';
    }
    if (_phoneCtrl.text != (draft.phone ?? '')) {
      _phoneCtrl.text = draft.phone ?? '';
    }
    if (_zipCtrl.text != (draft.zipCode ?? '')) {
      _zipCtrl.text = draft.zipCode ?? '';
    }
    if (_nameCtrl.text != (draft.customerName ?? '')) {
      _nameCtrl.text = draft.customerName ?? '';
    }
    if (_emailCtrl.text != (draft.customerEmail ?? '')) {
      _emailCtrl.text = draft.customerEmail ?? '';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const OrderAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const _GreenHeader(title: 'Thông tin giao hàng'),
          _TextRow(
            label: 'Tên khách',
            controller: _nameCtrl,
            onChanged: (v) => notifier.setCustomerName(v),
          ),
          _TextRow(
            label: 'Email',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => notifier.setCustomerEmail(v),
          ),
          _DropdownRow(
            label: 'Quốc gia',
            value: draft.country,
            onChanged: (v) => notifier.setCountry(v),
            items: const ['Việt Nam'],
          ),
          _DropdownRow(
            label: 'Tỉnh/ Thành phố',
            value: draft.city,
            items: const ['Tp Hồ Chí Minh', 'Hà Nội'],
            onChanged: (v) => notifier.setCity(v),
          ),
          _TextRow(
            label: 'zipCode',
            controller: _zipCtrl,
            keyboardType: TextInputType.text,
            onChanged: (v) => notifier.setZipCode(v),
          ),
          _DropdownRow(
            label: 'Hình thức giao hàng',
            value: draft.shippingMethod,
            items: const ['Giao cua nha vận chuyển', 'Nhận tại cửa hàng'],
            onChanged: (v) => notifier.setShippingMethod(v),
          ),
          _DropdownRow(
            label: 'Phương thức thanh toán',
            value: draft.paymentMethod,
            items: const ['Giao hàng thu tiền', 'Chuyển khoản'],
            onChanged: (v) => notifier.setPaymentMethod(v),
          ),
          _DropdownRow(
            label: 'Dịch vụ cộng thêm',
            value: draft.extraService,
            items: const ['Gói quà', 'Bảo hành mở rộng'],
            onChanged: (v) => notifier.setExtraService(v),
          ),
          _TextRow(
            label: 'Số điện thoại',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            onChanged: (v) => notifier.setPhone(v),
          ),
          _TextRow(
            label: 'Địa chỉ',
            controller: _addressCtrl,
            onChanged: (v) => notifier.setAddress(v),
          ),
          _TextRow(
            label: 'Ghi chú',
            controller: TextEditingController(text: draft.note ?? ''),
            onChanged: (v) => notifier.state = draft.copyWith(note: v),
            maxLines: 2,
          ),
          const _GreenHeader(title: 'Khuyến mãi'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoCtrl,
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
                onPressed: () {
                  // TODO: implement promo validation logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chưa triển khai kiểm tra mã khuyến mãi'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0062FF),
                ),
                child: const Text('Áp dụng'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _GreenHeader(title: 'Tổng kết phí'),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              children: [
                _VatRow(amount: draft.vat),
                _SummaryRow(
                  label: 'Phí ship',
                  value: '${draft.shippingFee.toStringAsFixed(0)} Vnd',
                ),
                _SummaryRow(
                  label: 'Tiền giảm',
                  value: '-${draft.discount.toStringAsFixed(0)} Vnd',
                ),
                const Divider(),
                _SummaryRow(
                  label: 'Thành tiền',
                  value: '${draft.total.toStringAsFixed(0)} Vnd',
                  bold: true,
                ),
              ],
            ),
          ),
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
                  backgroundColor: const Color(0xFF00CFFF),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/order/confirm');
                },
                child: const Text(
                  'Xác nhận thanh toán',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 112,
              height: 2,
              decoration: BoxDecoration(
                color: Color(0xFF595959),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreenHeader extends StatelessWidget {
  final String title;
  const _GreenHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF15753C),
        ),
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 39,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          icon: const Icon(Icons.expand_more),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          hint: Text(label),
        ),
      ),
    );
  }
}

class _TextRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;
  const _TextRow({
    required this.label,
    required this.controller,
    this.onChanged,
    this.keyboardType,
    this.maxLines,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 39,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        style: const TextStyle(fontSize: 12),
        onChanged: onChanged,
        maxLines: maxLines,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });
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
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _VatRow extends StatefulWidget {
  final double amount;
  const _VatRow({required this.amount});

  @override
  State<_VatRow> createState() => _VatRowState();
}

class _VatRowState extends State<_VatRow> {
  bool _checked = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: _checked,
            activeColor: const Color(0xFF0062FF),
            onChanged: (v) {
              setState(() => _checked = v ?? true);
            },
          ),
          const SizedBox(width: 4),
          const Text('VAT'),
          const Spacer(),
          Text('${widget.amount.toStringAsFixed(0)} Vnd'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:e_shoppe/features/order/order_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/data/repositories/order_repository.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  const OrderDetailPage({super.key});

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  Map<String, dynamic>? _order;
  bool _loading = true;
  String _status = 'pending';
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      final id = ModalRoute.of(context)?.settings.arguments as String? ?? '';
      _fetch(id);
      _didInit = true;
    }
  }

  Future<void> _fetch(String id) async {
    try {
      final ord = await ref.read(orderRepositoryProvider).getOrder(id);
      if (!mounted) return;
      setState(() {
        _order = ord;
        _status = ord['status'] as String? ?? 'pending';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _order = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _updateStatus() async {
    if (_order == null) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      await ref
          .read(orderRepositoryProvider)
          .updateStatus(_order!['id'], _status);
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Cập nhật thất bại')));
      }
    }
  }

  Future<void> _cancelOrder() async {
    if (_order == null) return;
    await ref
        .read(orderRepositoryProvider)
        .updateStatus(_order!['id'], 'cancelled');
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OrderAppBar(),
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Không tìm thấy đơn'))
              : _buildBody(),
      bottomNavigationBar: _order == null
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00CFFF)),
                  onPressed: _updateStatus,
                  child: const Text('Cập nhật đơn',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    final items = _order!['items'] as List<dynamic>;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const _SectionHeader('Thông tin đơn hàng'),
        _InfoRow(
            label: 'Mã đơn:', value: _order!['id'] ?? '', color: Colors.blue),
        _InfoRow(label: 'Sản phẩm:', value: items.length.toString()),
        _InfoRow(
            label: 'Ngày lập:',
            value: (_order!['createdAt'] ?? '').toString().substring(0, 10)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trạng thái:'),
              DropdownButton<String>(
                value: _status,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                      value: 'pending', child: Text('Chờ xác nhận')),
                  DropdownMenuItem(
                      value: 'confirmed', child: Text('Đã xác nhận')),
                  DropdownMenuItem(
                      value: 'shipped', child: Text('Đã gửi hàng')),
                  DropdownMenuItem(value: 'completed', child: Text('Hoàn tất')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Đã huỷ')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _SectionHeader('Trạng thái đơn hàng'),
        _StatusTimeline(current: _status),
        const SizedBox(height: 12),
        const _SectionHeader('Sản phẩm'),
        ...items.map((it) {
          final prod = it['product'] as Map<String, dynamic>;
          return ListTile(
            leading:
                Container(width: 56, height: 56, color: Colors.grey.shade300),
            title: Text(prod['name'] ?? ''),
            subtitle: Text('${prod['price']}'),
            trailing: Text('${it['quantity']}'),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () {}, child: const Text('In đơn')),
        const SizedBox(height: 6),
        OutlinedButton(
            onPressed: _cancelOrder,
            child: const Text('Huỷ đơn', style: TextStyle(color: Colors.red))),
      ],
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

class _StatusTimeline extends StatelessWidget {
  final String current;
  const _StatusTimeline({required this.current});

  static const _steps = [
    'pending',
    'confirmed',
    'shipped',
    'completed',
    'cancelled',
  ];

  Color _color(String step) {
    if (current == 'cancelled') {
      return step == 'cancelled' ? Colors.red : Colors.grey.shade300;
    }
    final idx = _steps.indexOf(step);
    final curIdx = _steps.indexOf(current);
    if (idx <= curIdx && curIdx >= 0) return Colors.green;
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _steps.map((s) => _dotWithLabel(s)).toList(),
    );
  }

  Widget _dotWithLabel(String step) {
    final color = _color(step);
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          _label(step),
          style: TextStyle(fontSize: 10, color: color),
        ),
      ],
    );
  }

  String _label(String s) {
    switch (s) {
      case 'pending':
        return 'Chờ';
      case 'confirmed':
        return 'Xác nhận';
      case 'shipped':
        return 'Gửi';
      case 'completed':
        return 'Hoàn tất';
      case 'cancelled':
        return 'Huỷ';
      default:
        return s;
    }
  }
}

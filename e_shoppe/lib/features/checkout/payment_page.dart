import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/blue_header.dart';
import '../../shared/widgets/section_card.dart';
import '../../theme/app_theme.dart';
import '../cart/bloc/cart_bloc.dart';
import 'order_success_page.dart';
import '../../shared/responsive.dart';
import '../order/riverpod/order_draft_provider.dart';
import '../../services/api_client.dart';
import '../../data/models/user.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

enum PayMethod { cod, vnpay }

class _PaymentPageState extends ConsumerState<PaymentPage> {
  PayMethod _method = PayMethod.cod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CartBloc, CartState>(builder: (context, state) {
        final content = Column(
          children: [
            const BlueHeader(title: 'Thanh toán'),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                      SectionCard(
                        title: 'Phương thức thanh toán',
                        child: Column(
                          children: [
                            RadioListTile<PayMethod>(
                              value: PayMethod.cod,
                              groupValue: _method,
                              title: const Text('Thanh toán khi nhận hàng'),
                              onChanged: (v) => setState(() => _method = v!),
                            ),
                            RadioListTile<PayMethod>(
                              value: PayMethod.vnpay,
                              groupValue: _method,
                              title: const Text('VNPay'),
                              onChanged: (v) => setState(() => _method = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SectionCard(
                        title: 'Tổng tiền',
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Thanh toán:'),
                              Text(_currency(state.total),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: AppColors.cyan,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    final draft = ref.read(orderDraftProvider);
                    if (draft.items.isEmpty) return;
                    final api = ref.read(apiProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đang gửi đơn hàng...')));
                    try {
                      final customer = draft.customer ??
                          const User(id: 'guest', name: 'Guest', email: '');
                      await api.post('/orders', {
                        'customer': {
                          'id': customer.id,
                          'name': customer.name,
                          'email': customer.email,
                        },
                        'items': draft.items
                            .map((e) => {
                                  'productId': e.product.id,
                                  'quantity': e.quantity,
                                })
                            .toList(),
                      });

                      // Clear local state
                      context.read<CartBloc>().add(const CartCleared());
                      ref.read(orderDraftProvider.notifier).clear();

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const OrderSuccessPage()),
                        (route) => route.isFirst,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Gửi đơn thất bại: $e')));
                    }
                  },
                  child: const Text('Xác nhận',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        );

        return Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: Responsive.maxBodyWidth(context)),
            child: content,
          ),
        );
      }),
    );
  }

  String _currency(double v) => '${v.toStringAsFixed(0)}đ';
}

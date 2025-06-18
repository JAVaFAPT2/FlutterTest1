import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/widgets/blue_header.dart';
import '../../shared/widgets/section_card.dart';
import '../../theme/app_theme.dart';
import '../cart/bloc/cart_bloc.dart';
import 'order_success_page.dart';
import '../../shared/responsive.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

enum PayMethod { cod, vnpay }

class _PaymentPageState extends State<PaymentPage> {
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
                  onTap: () {
                    context.read<CartBloc>().add(const CartCleared());
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const OrderSuccessPage()),
                      (route) => route.isFirst,
                    );
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

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart_item.dart';
import '../cart/bloc/cart_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../theme/app_theme.dart';
import '../../shared/widgets/blue_header.dart';
import '../../shared/widgets/section_card.dart';
import 'payment_page.dart';
import '../../shared/responsive.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated &&
        authState.user?.address != null &&
        _addressController.text.isEmpty) {
      // prefill the address only once so that user edits are preserved on rebuilds
      _addressController.text = authState.user!.address!;
    }
    return Scaffold(
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final content = Column(
            children: [
              const BlueHeader(title: 'Tạo đơn hàng'),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      const Center(
                        child: Text('Tạo đơn hàng',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            children: const [
                              SizedBox(width: 12),
                              Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Nhập SĐT/ Mã thẻ/ Tên khách hàng',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              Icon(Icons.close, color: Colors.grey),
                              SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SectionCard(
                          title: 'Thông tin khách hàng',
                          child: _CustomerInfoContent(
                              addressController: _addressController),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SectionCard(
                          title: 'Danh sách sản phẩm',
                          trailing: const SizedBox.shrink(),
                          child: _ProductSection(items: state.items),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              _TotalRow(
                                  label: 'Tiền giảm:',
                                  value: _currency(state.totalDiscount)),
                              _TotalRow(
                                  label: 'Tạm tính:',
                                  value: _currency(state.total)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: AppColors.cyan,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: GestureDetector(
                    onTap: state.items.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const PaymentPage()),
                            );
                          },
                    child: Text(
                      'Tiếp tục',
                      style: TextStyle(
                          color:
                              state.items.isEmpty ? Colors.grey : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
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
        },
      ),
    );
  }
}

String _currency(double val) => '${val.toStringAsFixed(0)}đ';

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}

class _CustomerInfoContent extends StatelessWidget {
  const _CustomerInfoContent({required this.addressController});

  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _infoRow(icon: Icons.person, text: user?.name ?? ''),
        _infoRow(icon: Icons.phone, text: user?.id ?? ''),
        _infoRow(icon: Icons.email, text: user?.email ?? ''),
        _infoRow(icon: Icons.location_on, text: addressController.text),
      ],
    );
  }

  Widget _infoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(text.isEmpty ? '-' : text)),
        ],
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    final cols = Responsive.gridColumnCount(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: cols == 1 ? 5 : 3,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _ProductRow(item: items[i]),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(width: 60, height: 60, color: Colors.green.shade200),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
                Text(_currency(item.product.price),
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                iconSize: 20,
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  context.read<CartBloc>().add(CartItemQuantityChanged(
                      productId: item.product.id, delta: -1));
                },
              ),
              Text(item.quantity.toString()),
              IconButton(
                iconSize: 20,
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  context.read<CartBloc>().add(CartItemQuantityChanged(
                      productId: item.product.id, delta: 1));
                },
              ),
            ],
          ),
          // discount row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Text('Giảm giá:'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(6),
                        hintText: '0'),
                    onSubmitted: (value) {
                      final discount = double.tryParse(value) ?? 0;
                      context.read<CartBloc>().add(CartItemDiscountChanged(
                          productId: item.product.id, discount: discount));
                    },
                  ),
                ),
                const SizedBox(width: 4),
                const Text('vnd'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

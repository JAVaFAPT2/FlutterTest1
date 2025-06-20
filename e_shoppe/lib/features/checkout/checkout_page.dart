// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/cart_item.dart';
import '../cart/bloc/cart_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../theme/app_theme.dart';
import '../../shared/widgets/blue_header.dart';
import '../../shared/widgets/section_card.dart';
import 'payment_page.dart';
import '../../shared/responsive.dart';
import 'package:e_shoppe/features/order/customer_search_page.dart';
import '../../data/models/user.dart';
import '../order/riverpod/order_draft_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/utils/formatter.dart';
import '../../shared/spacing.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Defer until widgets are built and Providers are available.
    Future.microtask(() {
      final cartBloc = context.read<CartBloc>();
      if (cartBloc.state.items.isEmpty) {
        final draft = ref.read(orderDraftProvider);
        if (draft.items.isNotEmpty) {
          for (final item in draft.items) {
            for (var i = 0; i < item.quantity; i++) {
              cartBloc.add(CartItemAdded(item.product));
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ref listener moved to build method to comply with Riverpod rules.
    ref.listen<OrderDraft>(orderDraftProvider, (prev, next) {
      final cartBloc = context.read<CartBloc>();
      // Rebuild cart state to mirror draft exactly.
      cartBloc.add(const CartCleared());
      for (final item in next.items) {
        for (var i = 0; i < item.quantity; i++) {
          cartBloc.add(CartItemAdded(item.product));
        }
        if (item.discountValue > 0) {
          cartBloc.add(CartItemDiscountChanged(
              productId: item.product.id, discount: item.discountValue));
        }
      }
    });
    final authState = context.watch<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated) {
      final user = authState.user!;
      if (_nameController.text.isEmpty && user.name != null) {
        _nameController.text = user.name!;
      }
      if (_phoneController.text.isEmpty && user.phone != null) {
        _phoneController.text = user.phone!;
      }
      if (_addressController.text.isEmpty && user.address != null) {
        _addressController.text = user.address!;
      }
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
                        padding: Gaps.page,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              final selected = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const CustomerSearchPage()),
                              );
                              if (selected != null && selected is User) {
                                // For now just show snackbar; integration can follow
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Đã chọn khách: ${selected.name}')),
                                );
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: const [
                                SizedBox(width: 12),
                                Icon(Icons.search, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Nhập SĐT/ Mã thẻ/ Tên khách hàng',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey),
                                SizedBox(width: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: Gaps.page,
                        child: SectionCard(
                          title: 'Thông tin khách hàng',
                          child: _CustomerInfoContent(
                            nameController: _nameController,
                            phoneController: _phoneController,
                            addressController: _addressController,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: Gaps.page,
                        child: SectionCard(
                          title: 'Danh sách sản phẩm',
                          trailing: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed('/order/select-product');
                            },
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.green, size: 18),
                            label: const Text('Thêm mới'),
                          ),
                          child: _ProductSection(items: state.items),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: Gaps.page,
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              _TotalRow(
                                  label: 'Tiền giảm:',
                                  value: formatCurrency(state.totalDiscount)),
                              _TotalRow(
                                  label: 'Tạm tính:',
                                  value: formatCurrency(state.total)),
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
                        : () async {
                            // update profile with current inputs
                            final repo = context.read<AuthRepository>();
                            final updated = await repo.updateProfile(
                              name: _nameController.text.trim(),
                              address: _addressController.text.trim(),
                              phone: _phoneController.text.trim(),
                            );
                            if (updated != null) {
                              context.read<AuthBloc>().add(LoggedIn(updated));
                            }
                            // Sync latest cart items into OrderDraft before proceeding
                            ref
                                .read(orderDraftProvider.notifier)
                                .setItems(state.items);

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
  const _CustomerInfoContent({
    required this.nameController,
    required this.phoneController,
    required this.addressController,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _editRow(
            icon: Icons.person,
            controller: nameController,
            hint: 'Tên khách hàng'),
        _editRow(icon: Icons.phone, controller: phoneController, hint: 'SĐT'),
        _infoRow(icon: Icons.email, text: user?.email ?? ''),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    hintText: 'Địa chỉ giao hàng',
                    isDense: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editRow(
      {required IconData icon,
      required TextEditingController controller,
      required String hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                isDense: true,
                border: const OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
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
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Chưa có sản phẩm'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.orange,
                            fontWeight: FontWeight.bold)),
                    Text(formatCurrency(item.product.price),
                        style: const TextStyle(
                            color: AppColors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  context.read<CartBloc>().add(CartItemQuantityChanged(
                      productId: item.product.id, delta: -1));
                },
                child: const Icon(Icons.remove_circle_outline, size: 20),
              ),
              const SizedBox(width: 4),
              Text(item.quantity.toString()),
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  context.read<CartBloc>().add(CartItemQuantityChanged(
                      productId: item.product.id, delta: 1));
                },
                child: const Icon(Icons.add_circle_outline, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('Giảm giá:'),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: item.discountValue > 0
                      ? item.discountValue.toStringAsFixed(0)
                      : '',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(6),
                      hintText: '0'),
                  onChanged: (value) {
                    final discount = double.tryParse(value) ?? 0;
                    // apply immediately as user types
                    context.read<CartBloc>().add(CartItemDiscountChanged(
                        productId: item.product.id, discount: discount));
                  },
                  onFieldSubmitted: (value) {
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
        ],
      ),
    );
  }
}

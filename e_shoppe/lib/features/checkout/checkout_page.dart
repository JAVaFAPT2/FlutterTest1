// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:e_shoppe/data/models/cart_item.dart';
import 'package:e_shoppe/features/cart/bloc/cart_bloc.dart';
import 'package:e_shoppe/features/auth/bloc/auth_bloc.dart';
import 'package:e_shoppe/theme/app_theme.dart';
import 'package:e_shoppe/shared/widgets/blue_header.dart';
import 'package:e_shoppe/shared/widgets/section_card.dart';
import 'package:e_shoppe/shared/responsive.dart';
import 'package:e_shoppe/features/order/customer_search_page.dart';
import 'package:e_shoppe/data/models/user.dart';
import 'package:e_shoppe/features/order/riverpod/order_draft_provider.dart';
import 'package:e_shoppe/data/repositories/auth_repository.dart';
import 'package:e_shoppe/shared/utils/formatter.dart';
import 'package:e_shoppe/shared/spacing.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Defer until widgets are built and Providers are available.
    Future.microtask(() {
      if (!mounted) return;
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
    _emailController.dispose();
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
                              // Capture context-dependent objects before the async gap.
                              final navigator = Navigator.of(context);

                              final selected = await navigator.push(
                                MaterialPageRoute(
                                    builder: (_) => const CustomerSearchPage()),
                              );
                              if (!mounted) return;
                              if (selected != null && selected is User) {
                                // No messenger needed after refactor; remove to avoid unused_local_variable warning.
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
                            emailController: _emailController,
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
                            // Capture dependencies before any await.
                            final navigator = Navigator.of(context);
                            final repo = context.read<AuthRepository>();
                            final authBloc = context.read<AuthBloc>();

                            final updated = await repo.updateProfile(
                              name: _nameController.text.trim(),
                              address: _addressController.text.trim(),
                              phone: _phoneController.text.trim(),
                            );
                            if (!mounted) return;
                            if (updated != null) {
                              authBloc.add(LoggedIn(updated));
                            }
                            final draftNotifier =
                                ref.read(orderDraftProvider.notifier);

                            // Push customer info from this page into draft
                            draftNotifier
                                .setCustomerName(_nameController.text.trim());
                            draftNotifier
                                .setCustomerEmail(_emailController.text.trim());
                            draftNotifier
                                .setPhone(_phoneController.text.trim());
                            draftNotifier
                                .setAddress(_addressController.text.trim());

                            // Sync cart items into draft
                            draftNotifier.setItems(state.items);

                            navigator.pushNamed('/order/shipping-info');
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
    required this.emailController,
    required this.addressController,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _editRow(
            icon: Icons.person,
            controller: nameController,
            hint: 'Tên khách hàng'),
        _editRow(icon: Icons.phone, controller: phoneController, hint: 'SĐT'),
        _editRow(
            icon: Icons.email,
            controller: emailController,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress),
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

  Widget _editRow({
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                isDense: true,
                border: const OutlineInputBorder(borderSide: BorderSide.none),
              ),
              autofillHints: const [],
              enableSuggestions: false,
              autocorrect: false,
            ),
          ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/data/models/user.dart';
import 'package:e_shoppe/data/repositories/customer_repository.dart';
import 'package:e_shoppe/features/order/order_app_bar.dart';

class CustomerSearchPage extends ConsumerStatefulWidget {
  const CustomerSearchPage({super.key});

  @override
  ConsumerState<CustomerSearchPage> createState() => _CustomerSearchPageState();
}

class _CustomerSearchPageState extends ConsumerState<CustomerSearchPage> {
  final _searchCtrl = TextEditingController();
  final _repo = CustomerRepository();
  Future<List<User>>? _future;

  void _search() {
    setState(() {
      _future = _repo.searchCustomers(_searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _repo.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: const OrderAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Nhập SDT/ tên khách hàng',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _search, child: const Text('Tìm')),
              ],
            ),
          ),
          if (_future == null)
            const Expanded(
                child: Center(child: Text('Nhập từ khoá để tìm khách hàng')))
          else
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final users = snapshot.data ?? [];
                  if (users.isEmpty) {
                    return const Center(
                        child: Text('Không tìm thấy khách hàng'));
                  }
                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final u = users[index];
                      return ListTile(
                        title: Text(u.name),
                        subtitle: Text(u.phone ?? u.email),
                        onTap: () {
                          Navigator.of(context).pop(u);
                        },
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'order_app_bar.dart';

class OrderFailurePage extends StatelessWidget {
  const OrderFailurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OrderAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, size: 96, color: Colors.red),
            const SizedBox(height: 24),
            const Text('Hệ thống đang bận xin hãy thử lại sau',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/orders', (route) => false);
              },
              child: const Text('về trang đơn hàng'),
            ),
          ],
        ),
      ),
    );
  }
}

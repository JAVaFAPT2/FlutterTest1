import 'package:flutter/material.dart';

import 'package:e_shoppe/shared/widgets/blue_header.dart';
import 'package:e_shoppe/theme/app_theme.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const BlueHeader(title: 'Thành công'),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 100, color: AppColors.green),
                  const SizedBox(height: 16),
                  const Text('Đơn hàng đã được tạo!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Về trang chính'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

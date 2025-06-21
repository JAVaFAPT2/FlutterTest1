import 'package:intl/intl.dart';

final _vnCurrency = NumberFormat('#,##0', 'vi_VN');

String formatCurrency(num value) {
  return '${_vnCurrency.format(value)}đ';
}

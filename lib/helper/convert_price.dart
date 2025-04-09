import 'package:intl/intl.dart';

String formatCurrency(int amount) {
  final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  return currencyFormatter.format(amount);
}
import "package:intl/intl.dart";

String formatAmount(double amount) {
  final format =
      NumberFormat.currency(locale: "en_US", symbol: "\$", decimalDigits: 2);

  return format.format(amount);
}

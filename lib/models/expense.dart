import 'package:isar/isar.dart';

// dart run build_runner build
part 'expense.g.dart';

@Collection()
class Expense {
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime date;

  Expense({
    required this.amount,
    required this.date,
    required this.name,
  });
}

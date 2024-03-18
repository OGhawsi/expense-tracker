import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;

  List<Expense> _allExpenses = [];

  // init db

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

// getter
  List<Expense> get allExpense => _allExpenses;

  // CRUD

  // create
  Future<void> createNewExpense(Expense expense) async {
    await isar.writeTxn(() => isar.expenses.put(expense));
    await readExpense();
  }

  // read
  Future<void> readExpense() async {
    List<Expense> fetchedExpense = await isar.expenses.where().findAll();

    _allExpenses.clear();
    _allExpenses = fetchedExpense;

    notifyListeners();
  }

  // get current month total

  Future<double> currentMonthTotal() async {
    await readExpense();

    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth &&
          expense.date.year == currentYear;
    }).toList();

    // calculate the total

    double total =
        currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);

    return total;
  }

  //Update
  Future<void> updateExpense(int id, Expense expense) async {
    expense.id = id;

    await isar.writeTxn(() => isar.expenses.put(expense));

    await readExpense();
  }

  // delete

  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));

    await readExpense();
  }

  // helpers

  // get total expense per month
  Future<Map<int, double>> calculateMonthlyTotals() async {
    // ensure fresh data from db
    await readExpense();

    // create a map {1: 220, 2:44...}
    Map<int, double> monthlyTotals = {};

    // fill out the map with months numbers and total expense per month
    for (var expense in allExpense) {
      int monthNumber = expense.date.month;

      // all the months that are not in the map initizlize them to 0
      if (!monthlyTotals.containsKey(monthNumber)) {
        monthlyTotals[monthNumber] = 0;
      }

      // add the total and put for the month munber in map
      monthlyTotals[monthNumber] = monthlyTotals[monthNumber]! + expense.amount;
    }
    return monthlyTotals;
  }

  // get the start month

  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.month;
  }
  // get the start week

  // get the start of the year

  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.year;
  }
}

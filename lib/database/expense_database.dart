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
    isar.writeTxn(() => isar.expenses.put(expense));
    await readExpense();
  }

  // read
  Future<void> readExpense() async {
    List<Expense> fetchedExpense = await isar.expenses.where().findAll();

    _allExpenses.clear();
    _allExpenses = fetchedExpense;

    notifyListeners();
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
}

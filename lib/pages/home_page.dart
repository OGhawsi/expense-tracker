import 'package:expense_tracker/bar%20graph/bar_graph.dart';
import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helper/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  Future<Map<int, double>>? _monthlyTotalsFuture;
  Future<double>? _currentMothTotal;

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpense();

    refreshData();

    super.initState();
  }

  void clearControllers() {
    nameController.clear();
    amountController.clear();
  }

  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();

    _currentMothTotal = Provider.of<ExpenseDatabase>(context, listen: false)
        .currentMonthTotal();
  }

  // open dialog box
  void openExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('New expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                ),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  hintText: 'Amounts',
                ),
              ),
            ],
          ),
          actions: [
            _cancelButton(),
            _saveButton(),
          ]),
    );
  }

  void openEditBox(Expense expense) {
    final existingName = expense.name;
    final existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: existingName,
              ),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                hintText: existingAmount,
              ),
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _updateButton(expense),
        ],
      ),
    );
  }

  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update expense'),
        actions: [
          _cancelButton(),
          _deleteButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        // calculate the number of months since the firest month [ for how man bars]

        int monthCount = calculateMonthCount(
            startYear, startMonth, currentYear, currentMonth);

        // Disply current month expenses only
        List<Expense> currentMonthExpenses = value.allExpense.where((expense) {
          return expense.date.year == currentYear &&
              expense.date.month == currentMonth;
        }).toList();

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey.shade300,
            floatingActionButton: FloatingActionButton(
              onPressed: openExpenseBox,
              child: const Icon(Icons.add),
            ),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: FutureBuilder<double>(
                future: _currentMothTotal,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text("\$${snapshot.data!.toStringAsFixed(2)}");
                  } else {
                    return const Text("Loading...");
                  }
                },
              ),
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final monthlyTotals = snapshot.data ?? {};

                        // create the list
                        List<double> monthlySummary = List.generate(
                          monthCount,
                          (index) => monthlyTotals[startMonth + index] ?? 0.0,
                        );

                        return MyBarGraph(
                            monthlySummary: monthlySummary,
                            startMonth: startMonth);
                      } else {
                        return const Center(
                          child: Text('loading...'),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentMonthExpenses.length,
                    itemBuilder: (context, index) {
                      // reverse the index to get the new first

                      int reversedIndex =
                          currentMonthExpenses.length - 1 - index;
                      Expense individualExpense =
                          currentMonthExpenses[reversedIndex];
                      return MyListTile(
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onEdit: (context) => openEditBox(individualExpense),
                        onDelete: (context) => openDeleteBox(individualExpense),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        clearControllers();
        Navigator.of(context).pop();
      },
      child: const Text("Cancel"),
    );
  }

  Widget _saveButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Expense newExpense = Expense(
            amount: double.parse(amountController.text),
            date: DateTime.now(),
            name: nameController.text,
          );

          // ignore: await_only_futures
          Navigator.of(context).pop();
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);
          refreshData();
          clearControllers();
        } else {
          clearControllers();
          Navigator.of(context).pop();
        }
      },
      child: const Text("Save"),
    );
  }

  Widget _updateButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          Navigator.of(context).pop();
          Expense updatedExpense = Expense(
            amount: amountController.text.isNotEmpty
                ? double.parse(amountController.text)
                : expense.amount,
            date: DateTime.now(),
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
          );

          int existingId = expense.id;

          // ignore: await_only_futures
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);
          refreshData();
          clearControllers();
        } else {
          clearControllers();
          Navigator.of(context).pop();
        }
      },
      child: const Text("Save"),
    );
  }

  Widget _deleteButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.of(context).pop();

        // ignore: await_only_futures
        await context.read<ExpenseDatabase>().deleteExpense(id);
        refreshData();
      },
      child: const Text("Delete"),
    );
  }
}

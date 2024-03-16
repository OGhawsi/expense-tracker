import 'package:expense_tracker/components/my_list_tile.dart';
import 'package:expense_tracker/database/expense_database.dart';
import 'package:expense_tracker/helper/helper_functions.dart';
import 'package:expense_tracker/models/expense.dart';
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

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpense();

    super.initState();
  }

  void clearControllers() {
    nameController.clear();
    amountController.clear();
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
      builder: (context, value, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: openExpenseBox,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
            itemCount: value.allExpense.length,
            itemBuilder: (context, index) {
              Expense individualExpense = value.allExpense[index];
              return MyListTile(
                title: individualExpense.name,
                trailing: formatAmount(individualExpense.amount),
                onEdit: (context) => openEditBox(individualExpense),
                onDelete: (context) => openDeleteBox(individualExpense),
              );
            }),
      ),
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
      },
      child: const Text("Delete"),
    );
  }
}

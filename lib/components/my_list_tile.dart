import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final void Function(BuildContext)? onEdit;
  final void Function(BuildContext)? onDelete;

  const MyListTile(
      {super.key,
      required this.title,
      required this.trailing,
      this.onEdit,
      this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: StretchMotion(),
        children: [
          SlidableAction(
            onPressed: onEdit,
            icon: Icons.settings,
          ),
          SlidableAction(
            onPressed: onDelete,
            icon: Icons.delete,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        trailing: Text(trailing),
      ),
    );
  }
}

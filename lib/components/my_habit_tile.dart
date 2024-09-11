import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final bool isCompleted;
  final String text;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;
  const MyHabitTile({
    super.key,
    required this.isCompleted,
    required this.text,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        // edit option
        SlidableAction(
          onPressed: editHabit,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          icon: Icons.edit,
          borderRadius: BorderRadius.circular(8),
        ),
        SlidableAction(
          onPressed: deleteHabit,
          backgroundColor: Colors.red,
          icon: Icons.delete,
          borderRadius: BorderRadius.circular(8),
        )

        // delete option
      ]),
      child: GestureDetector(
        onTap: () {
          if (onChanged != null) {
            // toggle the completion status
            onChanged!(!isCompleted);
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          padding: const EdgeInsets.all(12),
          child: ListTile(
            title: Text(text),
            leading: Checkbox(
                activeColor: Colors.green,
                value: isCompleted,
                onChanged: onChanged),
          ),
        ),
      ),
    );
  }
}

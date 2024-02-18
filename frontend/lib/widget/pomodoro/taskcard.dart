import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/state/todolist.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatelessWidget with StateMixin {
  final Task task;
  TaskCard({required this.task});

  bool get isSelected => todoListState.currentTask?.id == task.id;

  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();

    return Selector<TodoListState, String>(
      selector: (_, state) => "$isSelected-${task.isdone}-${task.finishTime}-${task.expectTime}",
      builder: (_, value, child) => ListTile(
        onTap: () {
          todoListState.setCurrentTask(task);
        },

        leading: task.isdone ? const Icon(Icons.check_box_outlined) : const Icon(Icons.check_box_outline_blank),
        title: Text(task.name),
        trailing: Text("${task.finishTime}/${task.expectTime}"),
        tileColor: isSelected ? Colors.blue[50] : null,
      ),
    );
  }

}
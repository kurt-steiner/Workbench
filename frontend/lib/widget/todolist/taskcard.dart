import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatelessWidget with StateMixin {
  final Task task;

  TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();

    return Container(
      color: Colors.white,
      margin: settings["widget.taskcard.margin"],
      child: ListTile(
        onTap: () {
          todoListState.setCurrentTask(task);
          scaffoldGlobalKey.currentState!.openEndDrawer();
        },

        leading: Checkbox(
          value: task.isdone,
          onChanged: (bool? value) async {
            if (value != null) {
              final request = UpdateTaskRequest(id: task.id, isdone: value);
              await todoListState.updateTaskAtCurrent(request);
            }
          },
        ),

        title: Text(task.name),
        subtitle: buildSubTitle(context),
        trailing: Text("${task.finishTime}/${task.expectTime}"),
      ),
    );
  }
  
  Widget? buildSubTitle(BuildContext context) {
    final List<Widget> children = [];
    
    if (task.note != null) {
      children.add(const Icon(Icons.note_alt_outlined));
    }

    if (task.subtasks.isNotEmpty) {
      int finishCount = task.subtasks.fold(0, (previousValue, element) {
        if (element.isdone) {
          return previousValue + 1;
        } else {
          return previousValue;
        }
      });

      children.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.list),
            Text("$finishCount/${task.subtasks.length}")
          ],
        )
      );
    }

    task.tags.forEach((tag) {
      children.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tag, color: tag.color,),
            Text(tag.name)
          ],
        )
      );
    });

    if (children.isEmpty) {
      return null;
    }

    return Wrap(
      children: children,
    );
  }
}
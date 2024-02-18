import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/page/todolist/task-detail.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:frontend/widget/pomodoro/taskcard.dart';
import 'package:frontend/widget/todolist/taskgroup.dart';
import 'package:frontend/widget/todolist/taskgroup-add.dart';
import 'package:provider/provider.dart';

class TaskGroupBoard extends StatelessWidget with StateMixin {
  List<TaskGroup> get taskGroups => todoListState.taskGroups;
  TaskProject get taskProject => todoListState.currentTaskProject!;
  Task? get currentTask => todoListState.currentTask;
  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();

    return Scaffold(
      key: scaffoldGlobalKey,
      appBar: AppBar(
        title: Text(taskProject.name),
        actions: [
          IconButton(
            onPressed: () {
              todoListNavigationKey.currentState!.pushNamed("todolist/taskproject", arguments: "edit");
            },

            icon: const Icon(Icons.edit_outlined),
          ),

          IconButton(
              onPressed: () async {
                todoListNavigationKey.currentState!.pop();
                await todoListState.deleteTaskProject(taskProject.id);
              },

              icon: const Icon(Icons.delete_forever_outlined, color: Colors.red,)
          ),
        ],
      ),
      endDrawer: TaskDetail(),

      body: Selector<TodoListState, String>(
        selector: (_, state) => state.taskGroups.map((e) => "${e.id}-${e.index}-${e.name}-${e.tasks.map((e) => e.id).toList()}").join(","),
        builder: (_, value, child) => ReorderableListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: taskGroups.length,
          itemBuilder: (_, index) {
            final taskGroup = taskGroups[index];
            return TaskGroupWidget(key: ValueKey("${taskGroup.id}-${taskGroup.name}-${taskGroup.index}"), taskGroup: taskGroup);
          },

          onReorder: (oldindex, newindex) async {
            // if newindex > oldindex, 这里 假设0和1互换，那么newindex为2
            if (newindex > oldindex) {
              newindex -= 1;
            }

            final taskGroup = todoListState.taskGroups[oldindex];
            final request = ReorderRequest(id: taskGroup.id, reorderAfter: newindex);
            await todoListState.reorderTaskGroup(request);
          },

          footer: TaskGroupAdd(),

        ),
      ),
    );
  }


}
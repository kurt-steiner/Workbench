import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/page/todolist/pomodoro-board.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:frontend/widget/todolist/taskadd.dart';
import 'package:frontend/widget/todolist/taskcard.dart';
import 'package:provider/provider.dart';

class TaskGroupWidget extends StatelessWidget with StateMixin {
  final TaskGroup taskGroup;

  TaskGroupWidget({super.key, required this.taskGroup});

  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();

    return SizedBox(
      width: settings["widget.taskgroup.width"],
      child: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          buildHead(context),
          TaskAdd(taskGroup: taskGroup),
          Expanded(
            child: ListView.builder(
                itemCount: taskGroup.tasks.length,
                itemBuilder: (context, index) => Selector<TodoListState, String>(
                    selector: (_, state) {
                      final task = taskGroup.tasks[index];
                      return "${task.id}-"
                          "${task.name}-"
                          "${task.index}-"
                          "${task.isdone}-"
                          "${task.parentid}-"
                          "${task.subtasks.map((e) => "${e.id}-${e.isdone}")}-"
                          "${task.tags.map((e) => "${e.id}-${e.name}-${e.color.toString()}-${task.note}-${task.expectTime}-${task.finishTime}").join(",")}";
                    },

                    builder: (_, value, child) {
                      final task = taskGroup.tasks[index];

                      final child = Material(
                        child: TaskCard(task: task,),
                      );

                      return Stack(
                        children: [
                          buildTaskDrag(context, task, child),
                          buildTaskDragTarget(context, task, child)
                        ],
                      );
                    }
                )
            ),
          )
        ],
      ),
    );
  }

  Widget buildHead(BuildContext context) {
    final controller = TextEditingController(text: taskGroup.name);

    final title = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none
            ),

            onSubmitted: (value) async {
              if (value.trim().isNotEmpty) {
                final request = UpdateTaskGroupRequest(
                    id: taskGroup.id, name: value.trim());

                await todoListState.updateTaskGroup(request);
              }
            },
          ),
        ),

        Text("${taskGroup.tasks.length}"),
      ],
    );

    return ListTile(
      contentPadding: settings["widget.taskcard.head.padding"],
      title: title,

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              todoListState.setCurrentTaskGroup(taskGroup);
              todoListNavigationKey.currentState?.pushNamed("todolist/pomodoro");
            },
            icon: const Icon(Icons.timer_outlined),
          ),

          buildMenu(context)
        ],
      )
    );
  }

  Widget buildMenu(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) => IconButton(
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },

        icon: const Icon(Icons.menu),
      ),

      menuChildren: [
        MenuItemButton(
            onPressed: () async {
              await todoListState.deleteTaskGroup(taskGroup.id);
              todoListState.setCurrentTaskGroup(null);
            },

            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete, color: Colors.red,),
                Text("删除任务列表", style: TextStyle(color: Colors.black),)
              ],
            )
        ),

      ],
    );
  }

  Widget buildTaskDrag(BuildContext context, Task task, Material child) {
    final feedback = SizedBox(
      width: settings["widget.taskgroup.width"] * 0.95,
      child: Opacity(opacity: 0.5, child: child,),
    );

    return LongPressDraggable<Task>(
      data: task,
      feedback: feedback,
      childWhenDragging: feedback,
      child: child,
    );
  }

  Widget buildTaskDragTarget(BuildContext context, Task task, Material child) {
    return DragTarget<Task>(
      onWillAccept: (from) => from?.id != task.id,
      onAccept: (from) async {
        final request = ReorderRequest(id: from.id, reorderAfter: task.index, parentid: task.parentid);
        if (task.index == 0) {
          request.reorderAfter += 1;
        }

        await todoListState.reorderTask(request, from, task);
      },

      builder: (context, datas, rejectedData) {
        if (datas.isEmpty) {
          // Container with only height will fill the width
          return Container(
            height: settings["widget.taskcard.height"],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 4,),
            ...datas.map<Widget>((e) => Opacity(opacity: 0.5, child: TaskCard(task: e!,),)).toList()
          ],
        );
      },
    );
  }

}
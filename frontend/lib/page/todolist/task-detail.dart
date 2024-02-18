import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:frontend/util/extensions.dart';
import 'package:frontend/util/random-color.dart';
import 'package:provider/provider.dart';

class TaskDetail extends StatefulWidget {
  @override
  _TaskDetailState createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> with StateMixin {
  Task get task => todoListState.currentTask!;
  List<SubTask> get subtasks => task.subtasks;

  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();

    // TODO using SingleChildScrollView
    return ValueListenableBuilder(
        valueListenable: todoListState.currentTaskNotifier,
        builder: (_, value, child) => value == null ? const SizedBox.shrink() : Drawer(
          elevation: 3,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                buildState(context),
                buildSubTasks(context),
                buildNotifyTime(context),
                buildDeadline(context),
                buildTimes(context),
                buildTags(context),
                buildInputTag(context),
                buildNote(context)
              ],
            ),
          ),
        )
    );
  }

  Widget buildState(BuildContext context) {
    final controller = TextEditingController(text: task.name);
    return Selector<TodoListState, String>(
      selector: (_, state) => "${task.name}-${task.isdone}",
      builder: (_, value, child) => ListTile(
        leading: Checkbox(
          value: task.isdone,
          onChanged: (bool? value) async {
            if (value != null) {
              final request = UpdateTaskRequest(id: task.id, isdone: value);
              await todoListState.updateTaskAtCurrent(request);
            }
          },
        ),

        title: TextField(
          controller: controller,
          onSubmitted: (String? value) async {
            if (value?.isNotEmpty ?? false) {
              final name = value!.trim();
              final request = UpdateTaskRequest(id: task.id, name: name);
              await todoListState.updateTaskAtCurrent(request);
            }
          },

          decoration: const InputDecoration(
            border: InputBorder.none,
          ),

          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        trailing: IconButton(
          onPressed: () async {
            scaffoldGlobalKey.currentState!.closeEndDrawer();
            await Future.delayed(const Duration(microseconds: 100));
            await todoListState.deleteTask(task.id);
          },

          icon: Icon(Icons.delete_forever_outlined, color: Colors.red,),
        ),
      ),
    );
  }

  Widget buildSubTasks(BuildContext context) {
    final controller = TextEditingController();
    return Selector<TodoListState, String>(
      selector: (_, state) => subtasks.map((e) => "${e.id}-${e.name}-${e.isdone}").join(","),
      builder: (_, value, child) => ReorderableListView.builder(
        shrinkWrap: true,
        itemCount: subtasks.length,
        onReorder: (oldindex, newindex) {

        },

        itemBuilder: (_, index) {
          final subtask = task.subtasks[index];
          final currentSubTaskController = TextEditingController(text: subtask.name);
          return ListTile(
            key: ValueKey("${subtask.id}-${subtask.name}"),
            leading: Checkbox(
              value: subtask.isdone,
              onChanged: (bool? value) async {
                if (value != null) {
                  final request = UpdateSubTaskRequest(id: subtask.id, isdone: value);
                  await todoListState.updateSubTaskAtCurrentTask(request);
                }
              },
            ),

            title: TextField(
              controller: currentSubTaskController,
              onSubmitted: (String? value) async {
                if (value != null) {
                  final request = UpdateSubTaskRequest(id: subtask.id, name: controller.text.trim());
                  await todoListState.updateSubTaskAtCurrentTask(request);
                }
              },

              decoration: const InputDecoration(
                  border: InputBorder.none,
              ),
            ),

            trailing: IconButton(
              onPressed: () async {
                await todoListState.deleteSubTaskAtCurrentTask(subtask.id);
              },

              icon: const Icon(Icons.close),
            ),
          );
        },

        footer: ListTile(
            leading: const Icon(Icons.add),
            title: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: task.subtasks.isEmpty ? "添加步骤" : "下一步",
              ),

              onSubmitted: (String? value) async {
                if (value != null && value.isNotEmpty) {
                  final request = PostSubTaskRequest(parentid: task.id, name: value.trim());
                  await todoListState.insertSubTaskAtCurrentTask(request);
                  controller.clear();
                }
              },
            )
        ),
      )
    );
  }

  Widget buildDeadline(BuildContext context) {
    return Selector<TodoListState, DateTime?>(
      selector: (_, state) => task.deadline,
      builder: (_, value, child) => ListTile(
        onTap: () async => await onPressDeadline(value != null),
        leading: const Icon(Icons.calendar_month),
        title: value == null ? const Text("添加截止日期") : Text("${value.year}-${value.month}-${value.day}-${value.hour}-${value.minute}"),
        trailing: value != null ? IconButton(
          onPressed: () async {
            await todoListState.removeDeadline(task.id);
          },

          icon: const Icon(Icons.close),
        ) : null,
      )
    );
  }

  Widget buildNotifyTime(BuildContext context) {
    return Selector<TodoListState, DateTime?>(
      selector: (_, state) => task.notifyTime,
      builder: (_, value, child) => ListTile(
        onTap: () async => await onPressNotifyTime(value != null),
        leading: const Icon(Icons.notifications_active_outlined),
        title: value == null ? const Text("提醒我") : Text("${value.year}-${value.month}-${value.day}-${value.hour}-${value.minute}"),
        trailing: value != null ? IconButton(
            onPressed: () async {
              await todoListState.removeNotifyTime(task.id);
            },

            icon: const Icon(Icons.close)
        ) : null,
      ),
    );
  }

  Widget buildTimes(BuildContext context) {
    return Selector<TodoListState, int>(
      selector: (_, state) => task.expectTime,
      builder: (_, value, child) => ListTile(
        leading: const Icon(Icons.alarm),
        title: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.1),
          ),

          child: Text(value.toString()),
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async {
                if (value > 1) {
                  final request = UpdateTaskRequest(id: task.id, expectTime: value - 1);
                  await todoListState.updateTaskAtCurrent(request);
                }
              },

              icon: const Icon(Icons.arrow_drop_down_outlined),
            ),

            IconButton(
              onPressed: () async {
                final request = UpdateTaskRequest(id: task.id, expectTime: value + 1);
                await todoListState.updateTaskAtCurrent(request);
              },

              icon: const Icon(Icons.arrow_drop_up_outlined),
            )

          ],
        ),
      ),
    );
  }

  Widget buildNote(BuildContext context) {
    final controller = TextEditingController(text: task.note);
    final notifier = ValueNotifier(task.note ?? "");

    return Selector<TodoListState, String?>(
      selector: (_, state) => task.note,
      builder: (_, value, child) => ListTile(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 5,
              minLines: 3,
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "添加备注"
              ),

              onChanged: (String? value) {
                notifier.value = value ?? "";
              },
            ),

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await todoListState.removeNoteAtCurrentTask();
                      controller.clear();
                    },

                    child: const Text("清空")
                ),
                ValueListenableBuilder(
                  valueListenable: notifier,
                  builder: (_, value, child) => ElevatedButton(
                    onPressed: value.isEmpty ? null : () async {
                      final request = UpdateTaskRequest(id: task.id, note: value);
                      await todoListState.updateTaskAtCurrent(request);
                    },

                    child: const Text("保存"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildTags(BuildContext context) {
    return Selector<TodoListState, int>(
      selector: (_, state) => task.tags.length,
      builder: (_, value, child) {
        final menuChildren = todoListState
            .tags
            .where((element) => !(task.tags.contains(element)))
            .map<Widget>(
                (e) => MenuItemButton(
                  onPressed: () async {
                    await todoListState.insertTagAtCurrent(e.id);
                  },
                  leadingIcon: Icon(Icons.tag, color: e.color,),
                  child: Text(e.name),
                )).toList();


        final wrapChildren = task.tags.map<Widget>(
                (e) =>  InputChip(
              backgroundColor: e.color.withOpacity(0.3),
              side: BorderSide.none,
              avatar: Icon(Icons.tag, color: e.color,),
              label: Text(e.name,),
              onDeleted: () async {
                await todoListState.removeTagAtCurrentTask(e.id);
              },
            )
        ).toList();

        if (wrapChildren.isEmpty) {
          wrapChildren.add(const Text(
            "选择标签"
          ));
        }

        return MenuAnchor(
          menuChildren: menuChildren,
          builder: (context, controller, child) => ListTile(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            leading: const Icon(Icons.tag),
            title: Wrap(
              children: wrapChildren
            ),
          ),
        );
      },
    );
  }

  Widget buildInputTag(BuildContext context) {
    final controller = TextEditingController();
    return ListTile(
      leading: const Icon(Icons.tag),
      title: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "添加标签"
        ),

        onSubmitted: (String? value) async {
          if (value != null) {
            final postRequest = PostTagRequest(name: value, parentid: todoListState.currentTaskProject!.id, color: randomColor());
            await todoListState.insertTag(postRequest);
            await todoListState.insertTagAtCurrent(todoListState.tags.last.id);

            controller.clear();
          }
        },
      ),
    );
  }
  Widget buildPriority(BuildContext context) {
    throw UnimplementedError();
  }

  Future<void> onPressDeadline(bool exist) async {
    final now = DateTime.now();
    DateTime? datetime;

    if (exist) {
      datetime = await showDatePicker(
        context: context,
        firstDate: now,
        lastDate: now.add(const Duration(days: 30)),
        cancelText: "删除",
        builder: (context, child) => PopScope(
          canPop: false,
          child: child!,
        )
      );
    } else {
      datetime = await showDatePicker(
          context: context,
          firstDate: now,
          lastDate: now.add(const Duration(days: 30))
      );
    }

    if (datetime != null) {
      final timeOfDay = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (timeOfDay != null) {
        final request = UpdateTaskRequest(
          id: task.id,
          deadline: DateTime(datetime.year, datetime.month, datetime.day, timeOfDay.hour, timeOfDay.minute)
        );

        await todoListState.updateTaskAtCurrent(request);
      }
    } else if (datetime == null && exist) {
      await todoListState.removeDeadline(task.id);
    }
  }

  Future<void> onPressNotifyTime(bool exist) async {
    final now = DateTime.now();
    DateTime? datetime;

    if (exist) {
      datetime = await showDatePicker(
          context: context,
          firstDate: now,
          lastDate: now.add(const Duration(days: 30)),
          cancelText: "删除",
          builder: (context, child) => PopScope(
            canPop: false,
            child: child!,
          )
      );
    } else {
      datetime = await showDatePicker(
        context: context,
        firstDate: now,
        lastDate: now.add(const Duration(days: 30))
      );
    }

    if (datetime != null) {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now()
      );

      if (timeOfDay != null) {
        final request = UpdateTaskRequest(id: task.id, notifyTime: DateTime(datetime.year, datetime.minute, datetime.day, timeOfDay.hour, timeOfDay.minute));
        await todoListState.updateTaskAtCurrent(request);
      }
    } else if (datetime == null && exist) {
      await todoListState.removeNotifyTime(task.id);
    }
  }

}
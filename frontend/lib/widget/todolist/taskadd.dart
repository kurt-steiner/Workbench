import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:frontend/widget/pomodoro/taskcard.dart';
import 'package:provider/provider.dart';

class TaskAdd extends StatefulWidget {
  final TaskGroup taskGroup;

  TaskAdd({required this.taskGroup});

  @override
  _TaskAddState createState() => _TaskAddState();
}

class _TaskAddState extends State<TaskAdd> with StateMixin {
  final controller = TextEditingController();
  late PostTaskRequest request;
  bool selectedDeadline = false;
  bool selectedNotifyTime = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    request = PostTaskRequest(name: "", parentid: widget.taskGroup.id, expectTime: 1);
  }

  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();

    return Stack(
      children: [
        buildCard(context),

      ],
    );
  }

  Widget buildCard(BuildContext context) {
    final card = Card(
      color: Colors.white,
      margin: todoListSettings["widget.taskcard.margin"],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTaskAddTextField(context),
          buildTaskAddFooter(context)
        ],
      ),
    );

    final dragTarget = DragTarget<Task>(
      onWillAccept: (from) => !(from?.index == 0 && from?.parentid == widget.taskGroup.id),
      onAccept: (from) async {
        final request = ReorderRequest(id: from.id, reorderAfter: 0, parentid: widget.taskGroup.id);
        await todoListState.reorderTask(request, from, null);
      },

      builder: (context, datas, rejectedData) {
        if (datas.isEmpty) {
          return Container(
            height: todoListSettings["widget.taskgroup.add.height"],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            card,
            const SizedBox(height: 4,),
            TaskCard(task: datas.first!)
          ],
        );
      },
    );

    return Stack(
      children: [
        card,
        dragTarget
      ],
    );
  }

  Widget buildTaskAddTextField(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.add, color: Colors.blue,),
      title: TextField(
        controller: controller,
        decoration: const InputDecoration(
            hintText: "添加任务",
            border: InputBorder.none
        ),
      ),
    );
  }

  Widget buildTaskAddFooter(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.05),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final date = await showDatePicker(
                      context: context,
                      firstDate: now, lastDate: now.add(const Duration(days: 30))
                  );

                  if (date != null) {
                    // request.deadline = result;
                    final timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now()
                    );

                    if (timeOfDay != null) {
                      request.deadline = DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);

                      setState(() {
                        selectedDeadline = true;
                      });
                    }
                  }
                },

                icon: Icon(Icons.calendar_month, color: selectedDeadline ? Colors.blue : null,),
              ),

              IconButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final date = await showDatePicker(
                      context: context,
                      firstDate: now, lastDate: now.add(const Duration(days: 30))
                  );

                  if (date != null) {
                    // request.deadline = result;
                    final timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now()
                    );

                    if (timeOfDay != null) {
                      request.notifyTime = DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);

                      setState(() {
                        selectedNotifyTime = true;
                      });
                    }
                  }

                },

                icon: Icon(Icons.notifications_active_outlined, color: selectedNotifyTime ? Colors.blue : null,),
              )
            ],
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  clear();
                },

                child: const Text("清空"),
              ),

              TextButton(
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    request.name = text;
                    await todoListState.insertTask(request);

                    clear();
                  }
                },

                child: const Text("添加"),
              ),
            ],
          )
        ],
      ),
    );
  }

  void clear() {
    request = PostTaskRequest(
        parentid: widget.taskGroup.id,
        name: "",
        note: null,
        priority: null,
        deadline: null,
        notifyTime: null,
        expectTime: 1
    );

    controller.clear();

    setState(() {
      selectedDeadline = false;
      selectedNotifyTime = false;
    });
  }
}
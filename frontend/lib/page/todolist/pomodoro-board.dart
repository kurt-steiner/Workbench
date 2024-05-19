import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:frontend/widget/pomodoro/pomodoro.dart';
import 'package:frontend/widget/pomodoro/taskcard.dart';
import 'package:provider/provider.dart';

class PomodoroBoard extends StatelessWidget with StateMixin {
  List<Task> get tasks => todoListState.currentTaskGroup?.tasks ?? [];

  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();

    return Scaffold(
      appBar: AppBar(title: const Text("Pomodoro"),),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Center(
      child: SizedBox(
        width: todoListSettings["widget.pomodoro.counter.width"],
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            CounterWidget(),
            buildCurrentTask(context),
            Expanded(child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (_, index) => TaskCard(task: tasks[index])
            ))
          ],
        ),
      ),
    );
  }

  Widget buildCurrentTask(BuildContext context) {
    return Selector<TodoListState, String>(
      selector: (_, state) => "${state.currentTask?.id}-${state.currentTask?.name}",
      builder: (_, value, child) => Align(alignment: Alignment.centerLeft, child: Text(todoListState.currentTask?.name ?? "")),
    );
  }

}


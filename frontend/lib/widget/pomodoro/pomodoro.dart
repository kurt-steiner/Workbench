import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:frontend/util/counter.dart';
import 'package:provider/provider.dart';

class CounterWidget extends StatelessWidget with StateMixin {
  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();

    return Card(
      elevation: 3,
      child: Container(
        width: settings["widget.pomodoro.counter.width"],
        margin: settings["widget.pomodoro.counter.margin"],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildFocusButton(context),
            buildTimeText(context),
            buildClickButton(context)
          ],
        ),
      ),
    );
  }

  Widget buildFocusButton(BuildContext context) {
    return Selector<TodoListState, FocusState>(
      selector: (_, state) => state.focusState,
      builder: (_, value, child) => Align(
        alignment: Alignment.center,
        heightFactor: 1,
        child: SegmentedButton(
          segments: const [
            ButtonSegment(value: FocusState.pomodoro, label: Text("pomodoro")),
            ButtonSegment(value: FocusState.shortBreak, label: Text("shortBreak")),
            ButtonSegment(value: FocusState.longBreak, label: Text("longBreak"))
          ],

          selected: {value},
          onSelectionChanged: (Set<FocusState> selection) {
            todoListState.focusState = selection.first;
          },
        ),
      ),
    );
  }

  Widget buildTimeText(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      widthFactor: 1.5,
      heightFactor: 1.2,
      child: Selector<TodoListState, String>(
        selector: (_, state) => state.counter.timeText,
        builder: (_, value, child) => Text(
          value,
          style: settings["widget.pomodoro.counter.time-text.style"],
        ),
      ),
    );
  }

  Widget buildClickButton(BuildContext context) {
    return Selector<TodoListState, bool>(
      selector: (_, state) => state.counter.state == RunningState.paused,
      builder: (_, value, child) => ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: settings["widget.pomodoro.counter.button.style.padding"],
            backgroundColor: Colors.white
          ),

          onPressed: () {
            if (value) {
              todoListState.startCountDown();
            } else {
              todoListState.stopCountDown();
            }
          },

          child: Text(value ? "START" : "STOP", style: settings["widget.pomodoro.counter.button.text-style"],)
      ),
    );
  }
}
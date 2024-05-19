import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/model/enumeration.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/daily-attendance.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatelessWidget with StateMixin {
  final da.Task task;

  TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    dailyAttendanceState = context.read<DailyAttendanceState>();

    return ListTile(
      onTap: task.progress is da.NotScheduled ? null : () {
        dailyAttendanceState.setCurrentTask(task);
        dailyAttendanceNavigationKey.currentState!.pushNamed("daily-attendance/task-record");
      },

      leading: buildIcon(context),
      title: Text(task.name),

      trailing: buildDays(context),
    );
  }

  Widget buildIcon(BuildContext context) {
    late Color color;
    late Widget icon;
    if (task.icon is da.Word) {
      final taskIcon = task.icon as da.Word;
      color = flatUIColors[taskIcon.color]!;
      icon = Container(
        width: dailyAttendanceSettings["widget.taskcard.icon.size"],
        height: dailyAttendanceSettings["widget.taskcard.icon.size"],
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle
        ),

        child: Center(child: Text(taskIcon.char, style: const TextStyle(color: Colors.white),)),
      );
    } else {
      final taskIcon = task.icon as da.Image;
      color = flatUIColors[taskIcon.backGroundColor]!;
      icon = Container(
        width: dailyAttendanceSettings["widget.taskcard.icon.size"],
        height: dailyAttendanceSettings["widget.taskcard.icon.size"],
        decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle
        ),

        child: Center(
            child: FractionallySizedBox(
                heightFactor: 0.8,
                child: Image.network(dailyAttendanceState.imageUrl(taskIcon.entryId), color: color,)
            )
        ),
      );
    }

    return icon;
  }

  Widget buildDays(BuildContext context) {
    return Selector<DailyAttendanceState, ShowMode>(
      selector: (_, state) => state.mode,
      builder: (_, value, child) {
        late Widget text;
        late Widget days;

        if (value == ShowMode.persistence) {
          days = Text("${task.persistenceDays}天");
          text = Text("共坚持");
        } else {
          days = Text("${task.consecutiveDays}天");
          text = Text("连续坚持");
        }

        return InkWell(
          onTap: () {
            dailyAttendanceState.switchMode();
          },

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              days,
              text
            ],
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/page/error-page.dart';
import 'package:frontend/page/loading-page.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/daily-attendance.dart';
import 'package:frontend/widget/daily_attendance/taskcard.dart';
import 'package:provider/provider.dart';

class TaskPage extends StatelessWidget with StateMixin {
  static const weekDayMap = {
    "SUNDAY": "日",
    "MONDAY": "一",
    "TUESDAY": "二",
    "WEDNESDAY": "三",
    "THURSDAY": "四",
    "FRIDAY": "五",
    "SATURDAY": "六"
  };
  
  late List<String> weekDays;
  late List<int> days;
  
  TaskPage() {
    final lastDay = DateTime.now();
    final prev6Day = lastDay.subtract(const Duration(days: 6));
    days = [];
    DateTime currentTime = prev6Day;
    final end = lastDay.add(const Duration(days: 1));
    
    while (currentTime.isBefore(end)) {
      days.add(currentTime.day);
      currentTime = currentTime.add(const Duration(days: 1));
    }
    
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    dailyAttendanceState = context.read<DailyAttendanceState>();
    return FutureBuilder(
        future: dailyAttendanceState.findAllOfLatest7Days(), 
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return ErrorPage(error: snapshot.error);
          }

          if (!snapshot.hasData) {
            return LoadingPage();
          }

          return Scaffold(
            appBar: AppBar(
              actions: [
                TextButton(
                  onPressed: () {
                    dailyAttendanceNavigationKey.currentState!.pushNamed("daily-attendance/statistics");
                  },

                  child: const Text("统计"),
                ),

                TextButton(
                  onPressed: () {
                    dailyAttendanceNavigationKey.currentState!.pushNamed("daily-attendance/manage");
                  },

                  child: const Text("归档管理"),
                )
              ],

              title: buildDateSelect(context),
            ),

            body: buildTasks(context),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                dailyAttendanceNavigationKey.currentState!.pushNamed("daily-attendance/task-add");
              },

              child: const Icon(Icons.add),
            ),
          );
        }
    );

    
  }

  Widget buildDateSelect(BuildContext context) {
    weekDays = dailyAttendanceState.weekDays;

    return Selector<DailyAttendanceState, String?>(
      selector: (_, state) => state.currentDay,
      builder: (_, value, child) {
        final segments = weekDays.map<ButtonSegment<String>>((e) => ButtonSegment(
          value: e,
          label: Text(weekDayMap[e]!),
        )).toList();

        final selected = weekDays.firstWhere((element) => element == dailyAttendanceState.currentDay);

        return SegmentedButton<String>(
          showSelectedIcon: false,
            segments: segments,
            onSelectionChanged: (Set<String> newSelection) {
              dailyAttendanceState.setCurrentDay(newSelection.first);
            },

            selected: {
              selected
            }
        );
      },
    );
  }

  Widget buildTasks(BuildContext context) {
    return Selector<DailyAttendanceState, String>(
      selector: (_, state) {
        String item1 = state.currentDay.toString();
        String item2 = state.tasks.entries
            .map((entry) => "${entry.key}-${entry.value.map((e) => e.toString()).join(",")}")
            .join(",");

        return "$item1-$item2";
      },

      builder: (_, value, child) {
        final sortedKeys = dailyAttendanceState.tasks.keys.toList()..sort();
        return ListView.builder(
            itemCount: sortedKeys.length,
            itemBuilder: (_, index) {
              da.Group key = sortedKeys[index];
              return buildTasksPart(context, key, dailyAttendanceState.tasks[key]!);
            }
        );
      },
    );
  }

  Widget buildTasksPart(BuildContext context, da.Group key, List<da.Task> tasks) {
    final children = tasks.where((element) => element.progress is! da.NotScheduled)
        .map<Widget>((e) => TaskCard(task: e)).toList();

    if (children.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return Card(
        child: ListTile(
          leading: Text(key.stringChinese()),
          title: Column(
              mainAxisSize: MainAxisSize.min,
              children: children
          ),
        ),
      );
    }
  }


}
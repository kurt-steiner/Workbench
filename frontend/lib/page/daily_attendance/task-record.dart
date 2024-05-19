import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/enumeration.dart';
import 'package:frontend/page/daily_attendance/color-select.dart';
import 'package:frontend/request/daily-attendance.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/daily-attendance.dart';
import 'package:frontend/widget/daily_attendance/switcher.dart';
import 'package:provider/provider.dart';
import 'package:frontend/model/daily-attendance.dart' as da;

class TaskRecord extends StatefulWidget {
  @override
  State<TaskRecord> createState() => _TaskRecordState();
}

class _TaskRecordState extends State<TaskRecord> with StateMixin {
  da.Task get currentTask => dailyAttendanceState.currentTask!;

  late SwitcherController controller;
  bool isRecorded = false;

  @override
  void initState() {
    super.initState();
    controller = SwitcherController(value: false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dailyAttendanceState = context.read<DailyAttendanceState>();

    return Selector<DailyAttendanceState, Color>(
      selector: (_, state) => backGroundColor(),
      builder: (_, value, child) {
        return Scaffold(
          appBar: buildAppBar(context, value),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: value
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildBackGroundImage(context),
                buildTaskName(context),
                const SizedBox(height: 4,),
                buildSwitcher(context),
                const SizedBox(height: 12,),
                buildProgressIndicator(context)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildBackGroundImage(BuildContext context) {
    return Selector<DailyAttendanceState, int?>(
      selector: (_, state) {
        int? id;
        if (currentTask.icon is da.Image) {
          id = (currentTask.icon as da.Image).backGroundId;
        }

        return id;
      },

      builder: (_, value, child) {
        if (value == null) {
          return Image.asset(
            "assets/record.png",
            width: dailyAttendanceSettings["page.task-record.background.icon.size"],
            height: dailyAttendanceSettings["page.task-record.background.icon.size"],
          );
        } else {
          return Image.network(
            dailyAttendanceState.imageUrl(value),
            width: dailyAttendanceSettings["page.task-record.background.icon.size"],
            height: dailyAttendanceSettings["page.task-record.background.icon.size"],
          );
        }
      },
    );
  }

  Color backGroundColor() {
    Color? color;
    if (currentTask.icon is da.Image) {
      color = flatUIColors[(currentTask.icon as da.Image).backGroundColor];
    }

    return color ?? flatUIColors[ColorSelect.defaultColor]!;
  }

  AppBar buildAppBar(BuildContext context, Color backGroundColor) {
    return AppBar(
      backgroundColor: backGroundColor,
      actions: [
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              onPressed: () async {
                await dailyAttendanceState.resetCurrentTask();
                controller.value = false;
                isRecorded = false;
              },
              leadingIcon: const Icon(Icons.refresh),
              child: const Text("重置打卡"),
            ),

            MenuItemButton(
              onPressed: () async {
                dailyAttendanceNavigationKey.currentState!.pushNamed("daily-attendance/task-edit");
              },

              leadingIcon: const Icon(Icons.edit),
              child: const Text("编辑"),
            ),

            MenuItemButton(
              onPressed: () async {
                UpdateArchiveTaskRequest request = UpdateArchiveTaskRequest(id: currentTask.id, isarchive: true);
                await dailyAttendanceState.updateArchive(request);
              },

              leadingIcon: const Icon(Icons.archive_outlined),
              child: const Text("归档"),
            ),

            MenuItemButton(
              leadingIcon: const Icon(Icons.delete_forever_outlined, color: Colors.red,),
              onPressed: () {
                showDialog(context: context, useRootNavigator: false, builder: (_) => AlertDialog(
                  title: const Text("删除习惯"),
                  content: const Text("确定删除这个习惯？删除后无法恢复"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        dailyAttendanceNavigationKey.currentState!.pop();
                      },

                      child: const Text("取消"),
                    ),

                    TextButton(
                      onPressed: () async {
                        dailyAttendanceNavigationKey.currentState!.popUntil(ModalRoute.withName("daily-attendance/task-page"));
                        await dailyAttendanceState.deleteTask(currentTask);
                      },

                      child: const Text("确定"),
                    )
                  ],
                ));
              },

              child: const Text("删除习惯"),
            )
          ],

          builder: (_, controller, child) => IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },

            icon: const Icon(Icons.more_vert),
          )

        )
      ],
    );
  }

  Widget buildTaskName(BuildContext context) {
    return Selector<DailyAttendanceState, String>(
      selector: (_, state) => currentTask.name,
      builder: (_, value, child) => Text(value, style: const TextStyle(color: Colors.white),),
    );
  }

  Widget buildSwitcher(BuildContext context) {
    return Selector<DailyAttendanceState, int>(
      selector: (_, state) => currentTask.id,
      builder: (_, id, child) {
        return StatefulBuilder(builder: (_, setState) {
          controller.value = currentTask.progress is da.Done || isRecorded;
          return Switcher(
              controller: controller,
              onChanged: (value) async {
                setState(() {
                  isRecorded = value;
                });
                await switcherOnChanged(value, id);
              }
          );
        });
      },
    );
  }

  Widget buildProgressIndicator(BuildContext context) {
    return Selector<DailyAttendanceState, (bool, double?)>(
      selector: (_, state) {
        bool value1 = currentTask.progress is da.Doing;
        double? value2;

        if (currentTask.progress is da.Done) {
          value2 = 1;
        } else if (currentTask.progress is! da.Doing) {
          value2 = null;
        } else {
          da.Doing progress = currentTask.progress as da.Doing;
          value2 = progress.amount / progress.total;
        }

        return (value1, value2);
      },

      builder: (_, value, child) {
        if (!value.$1 || value.$2 == null) {
          return const SizedBox.shrink();
        }

        return FractionallySizedBox(
          widthFactor: 0.5,
          child: LinearProgressIndicator(
            value: value.$2,
          ),
        );
      },
    );
  }

  Future<void> switcherOnChanged(bool value, int id) async {
    UpdateProgressRequest request = UpdateProgressRequest(id: id, progress: da.Ready());
    if (value) {
      switch (currentTask.goal.runtimeType) {
        case da.CurrentDay:
          request.progress = da.Done();
          break;
        case da.Amount:
          da.Amount goal = currentTask.goal as da.Amount;
          da.Progress progress = currentTask.progress;

          if (progress is da.Ready) {
            request.progress = da.Doing(total: goal.total, unit: goal.unit, amount: goal.eachAmount);
          } else if (progress is da.Doing) {
            request.progress = da.Doing(
                total: goal.total,
                unit: goal.unit,
                amount: (progress as da.Doing).amount + goal.eachAmount
            );
          } else {}

          break;
      }
    } else {
      switch (currentTask.goal.runtimeType) {
        case da.CurrentDay:
          request.progress = da.Ready();
          await dailyAttendanceState.resetCurrentTask();
          return;

        case da.Amount:
          da.Amount goal = currentTask.goal as da.Amount;
          da.Progress progress = currentTask.progress;

          if (progress is da.Doing || progress is da.Done) {
            request.progress = da.Doing(
                total: goal.total,
                unit: goal.unit,
                amount: goal.total - goal.eachAmount
            );
          }
          break;
      }
    }

    await dailyAttendanceState.updateProgress(request);
  }
}
import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/model/enumeration.dart';
import 'package:frontend/request/daily-attendance.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/daily-attendance.dart';
import 'package:provider/provider.dart';

class TaskManage extends StatefulWidget {
  @override
  _TaskManageState createState() => _TaskManageState();
}

class _TaskManageState extends State<TaskManage> with StateMixin, SingleTickerProviderStateMixin {
  List<da.Task> tasksOfKeeping = [];
  List<da.Task> tasksOfArchived = [];
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dailyAttendanceState = context.read<DailyAttendanceState>();

    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: controller,
          tabs: const [
            Tab(text: "坚持中",),
            Tab(text: "已归档",)
          ],
        ),
      ),

      body: TabBarView(
        controller: controller,
        children: [
          FutureBuilder(
              future: dailyAttendanceState.findAllTasks(false),
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.stackTrace);
                  return Center(child: Text(snapshot.error.toString()),);
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(),);
                }

                tasksOfKeeping = snapshot.requireData..sort();
                return Selector<DailyAttendanceState, int>(
                  selector: (_, state) => tasksOfKeeping.length,
                  builder: (_, value, child) => ListView.builder(
                    itemCount: value,
                    itemBuilder: (context, index) {
                      return buildItem(context, tasksOfKeeping[index]);
                    },
                  ),
                );
              }
          ),

          FutureBuilder(
            future: dailyAttendanceState.findAllTasks(true),
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.stackTrace);
                return Center(child: Text(snapshot.error.toString()),);
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(),);
              }

              tasksOfArchived = snapshot.requireData..sort();
              return Selector<DailyAttendanceState, int>(
                selector: (_, state) => tasksOfArchived.length,
                builder: (_, value, child) => ListView.builder(
                  itemCount: value,
                  itemBuilder: (context, index) {
                    return buildItem(context, tasksOfArchived[index]);
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, da.Task task) {
    return ListTile(
      leading: buildIcon(context, task.icon),
      title: Text(task.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              if (task.isarchived) {
                tasksOfArchived.removeWhere((element) => element.id == task.id);
                tasksOfKeeping.add(task);
                tasksOfKeeping.sort();

                UpdateArchiveTaskRequest request = UpdateArchiveTaskRequest(id: task.id, isarchive: false);
                await dailyAttendanceState.updateArchive(request);
              } else {
                tasksOfKeeping.removeWhere((element) => element.id == task.id);
                tasksOfArchived.add(task);
                tasksOfArchived.sort();

                UpdateArchiveTaskRequest request = UpdateArchiveTaskRequest(id: task.id, isarchive: true);
                await dailyAttendanceState.updateArchive(request);
              }
            },

            icon: task.isarchived ? const Icon(Icons.refresh) : const Icon(Icons.archive_outlined),
          ),

          IconButton(
            onPressed: () async {
              if (task.isarchived) {
                tasksOfArchived.removeWhere((element) => element.id == task.id);
              } else {
                tasksOfKeeping.removeWhere((element) => element.id == task.id);
              }

              await dailyAttendanceState.deleteTask(task);
            },

            icon: const Icon(Icons.delete, color: Colors.red,),
          )
        ],
      ),
    );
  }

  Widget buildIcon(BuildContext context, da.Icon icon) {
    late Color color;
    late Widget result;
    if (icon is da.Word) {
      final taskIcon = icon as da.Word;
      color = flatUIColors[taskIcon.color]!;
       result = Container(
        width: dailyAttendanceSettings["widget.taskcard.icon.size"],
        height: dailyAttendanceSettings["widget.taskcard.icon.size"],
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle
        ),

        child: Center(child: Text(taskIcon.char, style: const TextStyle(color: Colors.white),)),
      );
    } else {
      final taskIcon = icon as da.Image;
      color = flatUIColors[taskIcon.backGroundColor]!;
      result = Container(
        width: dailyAttendanceSettings["widget.taskcard.icon.size"],
        height: dailyAttendanceSettings["widget.taskcard.icon.size"],
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle
        ),

        child: Center(child: Image.network(dailyAttendanceState.imageUrl(taskIcon.entryId)),),
      );
    }

    return result;
  }


}
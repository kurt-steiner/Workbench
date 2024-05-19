import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/page/todolist/pomodoro-board.dart';
import 'package:frontend/page/todolist/taskgroup-board.dart';
import 'package:frontend/page/todolist/taskproject-board.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/daily-attendance.dart';
import 'package:frontend/state/todolist.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final todoListState = TodoListState(baseUrl: todoListSettings["common.urls.todolist-url"], uid: "Arch Linux");
    //
    // // TODO: implement build
    // return ChangeNotifierProvider(
    //   create: (_) => todoListState,
    //   child: MaterialApp(
    //     title: "Workbench Todolist",
    //     navigatorKey: todoListNavigationKey,
    //     initialRoute: "todolist/taskprojects",
    //     routes: todoListRoutes,
    //     debugShowCheckedModeBanner: false,
    //   )
    // );

    final plugin = FlutterLocalNotificationsPlugin();
    return FutureBuilder(
        future: plugin.initialize(const InitializationSettings(
          linux: LinuxInitializationSettings(
            defaultActionName: "Workbench Notification"
          )
        )),

        builder: (_, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return Center(child: Text(snapshot.error.toString()),);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(),);
          }

          final dailyAttendanceState = DailyAttendanceState(baseUrl: commonSettings["common.urls.base-url"], uid: "Arch Linux", plugin: plugin);
          tz.initializeTimeZones();
          return ChangeNotifierProvider(
            create: (_) => dailyAttendanceState,
            child: MaterialApp(
              title: "Workbench",
              navigatorKey: dailyAttendanceNavigationKey,
              initialRoute: "daily-attendance/task-page",
              routes: dailyAttendanceRoutes,
              debugShowCheckedModeBanner: false,
            ),
          );
        }
    );

  }
}
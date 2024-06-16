import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/page/daily_attendance/statistics.dart';
import 'package:frontend/page/home-page.dart';
import 'package:frontend/page/daily_attendance/color-select.dart';
import 'package:frontend/page/daily_attendance/task-add.dart';
import 'package:frontend/page/daily_attendance/task-edit.dart';
import 'package:frontend/page/daily_attendance/task-manage.dart';
import 'package:frontend/page/daily_attendance/task-record.dart';
import 'package:frontend/page/daily_attendance/taskpage.dart';
import 'package:frontend/page/todolist/pomodoro-board.dart';
import 'package:frontend/page/todolist/taskgroup-board.dart';
import 'package:frontend/page/todolist/taskproject-add-edit.dart';
import 'package:frontend/page/todolist/taskproject-board.dart';
import 'package:frontend/page/todolist/taskproject-manage.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/clipboard.dart';
import 'package:frontend/state/daily-attendance.dart';
import 'package:frontend/state/todolist.dart';
import 'package:frontend/util/keepalive.dart';
import 'package:provider/provider.dart';

class RootPage extends StatefulWidget {
  @override
  RootPageState createState() => RootPageState();
}

class RootPageState extends State<RootPage> with StateMixin, SingleTickerProviderStateMixin {
  Map<String, Widget>? _pageRecord;
  Map<String, Widget> get pageRecord => _pageRecord!;
  set pageRecord(Map<String, Widget> value) => _pageRecord ??= value;
  late TabController tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();
    dailyAttendanceState = context.read<DailyAttendanceState>();
    clipboardState = context.read<ClipboardState>();

    pageRecord = {
      "todolist": Navigator(
        key: todoListNavigationKey,
        initialRoute: todoListInitialRoute,
        onGenerateRoute: (settings) {
          late Widget pageChild;
          print(settings.name);
          if (settings.name!.endsWith("taskprojects")) {
            pageChild = TaskProjectBoard();
          } else if (settings.name!.endsWith("taskgroups")) {
            pageChild = TaskGroupBoard();
          } else if (settings.name!.endsWith("pomodoro")) {
            pageChild = PomodoroBoard();
          } else if (settings.name!.endsWith("taskproject")) {
            pageChild = TaskProjectAddEdit();
          } else if (settings.name!.endsWith("taskproject-manage")) {
            pageChild = TaskProjectManage();
          } else {
            throw UnimplementedError(
                "no such widget match the '${settings.name}'");
          }

          return MaterialPageRoute(
              builder: (_) => pageChild, settings: settings);
        },
      ),

      "daily-attendance": Navigator(
          key: dailyAttendanceNavigationKey,
          initialRoute: dailyAttendanceInitialRoute,
          onGenerateRoute: (settings) {
            late Widget pageChild;

            if (settings.name!.endsWith("task-page")) {
              pageChild = TaskPage();
            } else if (settings.name!.endsWith("task-record")) {
              pageChild = TaskRecord();
            } else if (settings.name!.endsWith("color-select")) {
              pageChild = ColorSelect();
            } else if (settings.name!.endsWith("task-add")) {
              pageChild = TaskAdd();
            } else if (settings.name!.endsWith("manage")) {
              pageChild = TaskManage();
            } else if (settings.name!.endsWith("task-edit")) {
              pageChild = TaskEdit();
            } else if (settings.name!.endsWith("statistics")){
              pageChild = StatisticsPage();
            } else {
              throw UnimplementedError(
                  "no such widget match the '${settings.name}'");
            }

            return MaterialPageRoute(
                builder: (_) => pageChild, settings: settings);
          }
      ),
    };


    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          StatefulBuilder(
            builder: (context, setState) =>  NavigationRail(
                onDestinationSelected: (index) {
                  tabController.index = index;
                  setState(() {
                    selectedIndex = index;
                  });
                },

                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      label: Text("主页"),
                      selectedIcon: Icon(Icons.home_outlined, color: Colors.blue,),
                  ),

                  NavigationRailDestination(
                    icon: Icon(Icons.list_alt),
                    label: Text("任务"),
                    selectedIcon: Icon(Icons.list_alt, color: Colors.blue,),
                  ),

                  NavigationRailDestination(
                    icon: Icon(Icons.task_alt),
                    label: Text("习惯打卡"),
                    selectedIcon: Icon(Icons.task_alt, color: Colors.blue,),
                  ),
                ],

                selectedIndex: selectedIndex
            ),
          ),

          const VerticalDivider(),

          Expanded(child: TabBarView(
            controller: tabController,
            children: [
              KeepAliveWrapper(child: HomePage()),
              KeepAliveWrapper(child: pageRecord["todolist"]!),
              KeepAliveWrapper(child: pageRecord["daily-attendance"]!)
            ],
          ))
        ],
      ),
    );
  }
}
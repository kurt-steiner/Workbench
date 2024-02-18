import 'package:flutter/material.dart';
import 'package:frontend/page/todolist/pomodoro-board.dart';
import 'package:frontend/page/todolist/taskgroup-board.dart';
import 'package:frontend/page/todolist/taskproject-board.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:provider/provider.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todoListState = TodoListState(baseUrl: settings["common.urls.todolist-url"], uid: "Arch Linux");

    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => todoListState,
      child: MaterialApp(
        title: "Workbench Todolist",
        navigatorKey: todoListNavigationKey,
        initialRoute: "todolist/taskprojects",
        routes: todoListRoutes,
        debugShowCheckedModeBanner: false,
      )
    );
  }
}
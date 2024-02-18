import 'package:flutter/material.dart';
import 'package:frontend/page/todolist/pomodoro-board.dart';
import 'package:frontend/page/todolist/taskgroup-board.dart';
import 'package:frontend/page/todolist/taskproject-add-edit.dart';
import 'package:frontend/page/todolist/taskproject-board.dart';
import 'package:frontend/page/todolist/taskproject-manage.dart';

const Map<String, dynamic> settings = {
  "widget.taskgroup.width": 400.0,
  "widget.taskcard.margin": EdgeInsets.all(4.0),
  "widget.taskcard.height": 24.0,
  "widget.taskcard.head.padding": EdgeInsets.only(left: 12.0),
  "widget.taskproject.width": 250.0,
  "widget.taskproject.height": 150.0,

  "widget.taskproject.cover.title.style": TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
  "widget.taskproject.cover.border-radius": BorderRadius.all(Radius.circular(8.0)),
  "widget.taskproject.cover.padding": EdgeInsets.all(16.0),
  "widget.pomodoro.counter.time-text.style": TextStyle(
    fontSize: 120,
    color: Colors.white,
    fontWeight: FontWeight.bold
  ),

  "widget.pomodoro.counter.button.text-style": TextStyle(
      fontSize: 22,
      color: Colors.black12,
      fontWeight: FontWeight.bold
  ),

  "widget.pomodoro.counter.button.style.padding": EdgeInsets.symmetric(horizontal: 60, vertical: 20),
  "widget.pomodoro.counter.margin": EdgeInsets.symmetric(vertical: 20),
  "widget.pomodoro.counter.width": 480.0,
  "widget.pomodoro.taskcard.select.width": 10.0,

  "state.todolist.pomodoro-time": 25,
  "state.todolist.short-break-time": 5,
  "state.todolist.long-break-time": 15,
  "state.todolist.long-break-interval": 4,
  "common.urls.todolist-url": "http://localhost:8080/",

  "page.taskdetail.tag-add.constraint": BoxConstraints(
    maxWidth: 100
  ),

  "page.taskproject-add-edit.image.height": 200.0
};

final todoListNavigationKey = GlobalKey<NavigatorState>();
final scaffoldGlobalKey = GlobalKey<ScaffoldState>();
Map<String, Widget Function(BuildContext)> todoListRoutes = {
  "todolist/taskprojects": (_) => TaskProjectBoard(),
  "todolist/taskgroups": (_) => TaskGroupBoard(),
  "todolist/pomodoro": (_) => PomodoroBoard(),
  "todolist/taskproject": (_) => TaskProjectAddEdit(),
  "todolist/taskproject-manage": (_) => TaskProjectManage()
};
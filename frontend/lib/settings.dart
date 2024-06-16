import 'package:flutter/material.dart';
import 'package:frontend/page/daily_attendance/color-select.dart';
import 'package:frontend/page/daily_attendance/statistics.dart';
import 'package:frontend/page/daily_attendance/task-edit.dart';
import 'package:frontend/page/daily_attendance/task-manage.dart';
import 'package:frontend/page/daily_attendance/task-record.dart';
import 'package:frontend/page/daily_attendance/task-add.dart';
import 'package:frontend/page/daily_attendance/taskpage.dart';
import 'package:frontend/page/todolist/pomodoro-board.dart';
import 'package:frontend/page/todolist/taskgroup-board.dart';
import 'package:frontend/page/todolist/taskproject-add-edit.dart';
import 'package:frontend/page/todolist/taskproject-board.dart';
import 'package:frontend/page/todolist/taskproject-manage.dart';

const Map<String, dynamic> commonSettings = {
  "common.urls.base-url": "http://localhost:8080/"
};

const Map<String, dynamic> todoListSettings = {
  "widget.taskgroup.width": 400.0,
  "widget.taskcard.margin": EdgeInsets.all(4.0),
  "widget.taskcard.height": 24.0,
  "widget.taskgroup.add.height": 50.0,
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


  "page.taskdetail.tag-add.constraint": BoxConstraints(
    maxWidth: 100
  ),

  "page.taskproject-add-edit.image.height": 200.0,
};

const Map<String, dynamic> dailyAttendanceSettings = {
  "widget.taskcard.icon.size": 50.0,
  "page.statistics.week.item.size": 32.0,
  "page.statistics.week.item.margin": EdgeInsets.all(4.0),
  "page.statistics.week.list.item.margin": EdgeInsets.symmetric(vertical: 4),
  "page.statistics.week.padding": EdgeInsets.only(left: 16.0),
  "page.statistics.calendar.item.size": 8.0,
  "page.statistics.calendar.item.margin": EdgeInsets.all(4.0),
  "page.statistics.calendar.item.padding": EdgeInsets.all(16.0),
  "page.statistics.week.head.font.size": 16.0,
  "page.taskadd.upload-icon.image.size": 100.0,
  "page.taskadd.color-select.size": 30.0,
  "widget.daily-attendance.checkbox.margin": EdgeInsets.symmetric(horizontal: 8),
  "widget.daily-attendance.checkbox.padding": EdgeInsets.all(8),
  "page.taskadd.edit-gaol.textfield.width": 40.0,
  "page.task-record.background.icon.size": 200.0,
  "widget.switcher.width": 200.0,
  "widget.switcher.height": 60.0,
  "widget.switcher.button.width": 60.0,
  "widget.switcher.button.height": 60.0
};

final todoListNavigationKey = GlobalKey<NavigatorState>();
final dailyAttendanceNavigationKey = GlobalKey<NavigatorState>();

final scaffoldGlobalKey = GlobalKey<ScaffoldState>();
const todoListInitialRoute = "todolist/taskprojects";

Map<String, Widget Function(BuildContext)> todoListRoutes = {
  "todolist/taskprojects": (_) => TaskProjectBoard(),
  "todolist/taskgroups": (_) => TaskGroupBoard(),
  "todolist/pomodoro": (_) => PomodoroBoard(),
  "todolist/taskproject": (_) => TaskProjectAddEdit(),
  "todolist/taskproject-manage": (_) => TaskProjectManage()
};


const dailyAttendanceInitialRoute = "daily-attendance/task-page";
Map<String, Widget Function(BuildContext)> dailyAttendanceRoutes = {
  "daily-attendance/task-page": (_) => TaskPage(),
  "daily-attendance/task-record": (_) => TaskRecord(),
  "daily-attendance/color-select": (_) => ColorSelect(),
  "daily-attendance/task-add": (_) => TaskAdd(),
  "daily-attendance/statistics": (_) => StatisticsPage(),
  "daily-attendance/manage": (_) => TaskManage(),
  "daily-attendance/task-edit": (_) => TaskEdit()
};
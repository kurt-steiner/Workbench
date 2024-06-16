import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/state/clipboard.dart';
import 'package:frontend/state/daily-attendance.dart';
import 'package:frontend/state/todolist.dart';

ValueNotifier<bool> loginIn = ValueNotifier(false);
String? uid;
String? baseUrl;
FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
ClipboardState? clipboardState;
TodoListState? todoListState;
DailyAttendanceState? dailyAttendanceState;
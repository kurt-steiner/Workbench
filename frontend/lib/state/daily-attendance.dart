import 'package:cron/cron.dart' show Cron, Schedule;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/api/daily-attendance.dart';
import 'package:frontend/api/image.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/request/daily-attendance.dart';
import 'package:path/path.dart' show join;

enum ShowMode {
  persistence,
  consecutive
}

class DailyAttendanceState extends ChangeNotifier {
  static Cron cron = Cron();
  late final DailyAttendanceApi api;
  late final ImageApi imageApi;
  final FlutterLocalNotificationsPlugin plugin;
  final Map<da.Group, List<da.Task>> tasks = Map();

  // 当天所有任务
  List<da.Task> tasksOfCurrentDay = [];
  ShowMode mode = ShowMode.persistence;
  Map<String, List<da.Task>> tasksOf7Days = Map();
  da.Task? currentTask;

  List<String> weekDays = [];
  String? currentDay;

  DailyAttendanceState({required String baseUrl, required String uid, required this.plugin}) {
    api = DailyAttendanceApi(baseUrl: baseUrl, uid: uid);
    imageApi = ImageApi(baseUrl: baseUrl, uid: uid);
  }

  String imageUrl(int id) => join(imageApi.url, "download", id.toString());

  void setCurrentDay(String day) {
    if (currentDay == day) {
      return;
    }

    currentDay = day;
    currentTask = null;

    final list = tasksOf7Days[day]!;
    tasks.clear();
    for (final task in list) {
      final group = task.group;

      if (tasks.containsKey(group)) {
        tasks[group]!.add(task);
      } else {
        tasks[group] = [task];
      }
    }

    notifyListeners();
  }

  void setCurrentTask(da.Task task) {
    currentTask = task;
    notifyListeners();
  }

  Future<void> insertTask(PostTaskRequest request) async {
    final task = await api.insertTask(request);

    /// if startTime == currentDay, then add it
    DateTime now = DateTime.now();
    if (task.startTime.year == now.year && task.startTime.month == now.month && task.startTime.day == now.day) {
      if (tasks.containsKey(task.group)) {
        tasks[task.group]!.insert(0, task);
      } else {
        tasks[task.group] = [task];
      }
    }

    for (final notifyTime in task.notifyTimes) {
      cron.schedule(Schedule.parse("${notifyTime.minute} ${notifyTime.hour} * * *"), () {
        plugin.show(task.id + 1, task.name, task.encouragement, null);
      });
    }

    notifyListeners();
  }

  Future<void> deleteTask(da.Task task) async {
    tasks[task.group]!.removeWhere((element) => element.id == task.id);
    await api.deleteTask(task.id);

    tasksOfCurrentDay.removeWhere((element) => element.id == task.id);
    restartNotificationOfCurrentDay();
    notifyListeners();
  }

  Future<void> updateTask(UpdateTaskRequest request) async {
    final task = await api.updateTask(request);
    List<da.Task>? list;

    for (final entry in tasks.entries) {
      final value = entry.value;
      final index = value.indexWhere((element) => element.id == request.id);

      if (index != -1) {
        list = value;
        break;
      }
    }

    final index = list!.indexWhere((element) => element.id == request.id);
    final oldGroup = list[index].group;
    final newGroup = task.group;

    if (oldGroup == newGroup) {
      list[index] = task;
    } else {
      list.removeWhere((element) => element.id == request.id);
      tasks[task.group]!.insert(0, task);
    }

    currentTask = task;

    restartNotificationOfCurrentDay();
    notifyListeners();
  }

  Future<void> updateProgress(UpdateProgressRequest request) async {
    final task = await api.updateProgress(request);

    for (final entry in tasksOf7Days.entries) {
      final list = entry.value;
      final index = list.indexWhere((element) => element.id == request.id);

      if (index != -1) {
        list[index] = task;
        break;
      }
    }

    for (final entry in tasks.entries) {
      final list = entry.value;
      final index = list.indexWhere((element) => element.id == request.id);

      if (index != -1) {
        list[index] = task;
        break;
      }
    }

    currentTask!.progress = task.progress;
    notifyListeners();
  }

  Future<void> updateArchive(UpdateArchiveTaskRequest request) async {
    await api.updateArchive(request);
    final task = await api.findTask(request.id);

    for (final entry in tasks.entries) {
      final key = entry.key;
      final list = entry.value;

      if (key == task.group) {
        if (request.isarchive) {
          list.removeWhere((element) => element.id == request.id);
        } else {
          list.insert(0, task);
        }

        break;
      }
    }

    final entry = tasksOf7Days.entries.last;
    final list = entry.value;

    if (request.isarchive) {
      list.removeWhere((element) => element.id == request.id);
    } else {
      final isAvailable = task.isarchived;
      if (isAvailable) {
        list.insert(0, task);
      }
    }

    currentTask = null;

    restartNotificationOfCurrentDay();
    notifyListeners();
  }

  Future<bool> findAllOfLatest7Days() async {
    final result = await api.findAllOfLatest7Days();
    tasksOf7Days = result;
    weekDays = tasksOf7Days.keys.toList();
    currentDay = weekDays.last;
    tasksOfCurrentDay = await api.findAllOfCurrentDay();

    tasks.clear();

    for (final task in tasksOf7Days[currentDay]!) {
      if (tasks.containsKey(task.group)) {
        tasks[task.group]!.add(task);
      } else {
        tasks[task.group] = [task];
      }
    }

    restartNotificationOfCurrentDay();
    notifyListeners();
    return true;
  }

  Future<void> resetCurrentTask() async {
    currentTask = await api.resetToday(currentTask!.id);

    final group = currentTask!.group;
    final list = tasks[group]!;
    final index = list.indexWhere((element) => element.id == currentTask!.id);
    list[index] = currentTask!;

    notifyListeners();
  }

  Future<Map<da.Task, List<da.Progress>>> statisticsWeekly(int offset) async {
    return await api.statisticsWeekly(offset);
  }

  Future<Map<da.Task, List<da.Progress>>> statisticsMonthly(int offset) async {
    return await api.statisticsMonthly(offset);
  }

  void switchMode() {
    if (mode == ShowMode.persistence) {
      mode = ShowMode.consecutive;
    } else {
      mode = ShowMode.persistence;
    }

    notifyListeners();
  }

  Future<List<da.Task>> findAllTasks(bool isarchive) async {
    return await api.findAllTasks(isarchive);
  }

  Future<da.Task> findTask(int id) async {
    return await api.findTask(id);
  }

  Future<void> restartNotificationOfCurrentDay() async {
    await cron.close();
    cron = Cron();
    for (final task in tasksOfCurrentDay) {
      for (final notifyTime in task.notifyTimes) {
        cron.schedule(Schedule.parse(
          "${notifyTime.minute} ${notifyTime.hour} * * *"
        ), () {
          plugin.show(task.id + 1, task.name, task.encouragement, null);
        });
      }
    }
  }
}
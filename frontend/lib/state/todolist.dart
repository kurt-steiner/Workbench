import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/image.dart';
import 'package:frontend/api/todolist.dart';
import 'package:frontend/model/image.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/util/counter.dart';
import 'package:path/path.dart' show join;
import 'package:frontend/global.dart' as global;

class TodoListState extends ChangeNotifier {
  List<TaskProject> taskProjects = [];
  List<TaskGroup> taskGroups = [];
  List<Priority> priorities = [];
  List<Tag> tags = [];
  Task? currentTask;
  TaskGroup? currentTaskGroup;
  TaskProject? currentTaskProject;
  late TodoListApi api;
  late ImageApi imageApi;
  Counter counter = Counter(pomodoroTime: todoListSettings["state.todolist.pomodoro-time"], shortBreakTime: todoListSettings["state.todolist.short-break-time"], longBreakTime: todoListSettings["state.todolist.long-break-time"], longBreakInterval: todoListSettings["state.todolist.long-break-interval"]);

  Timer? timer;

  late ValueNotifier<Task?> currentTaskNotifier;
  TodoListState() {
    currentTaskNotifier = ValueNotifier(currentTask);
    api = TodoListApi(baseUrl: global.baseUrl!, uid: global.uid!);
    imageApi = ImageApi(baseUrl: global.baseUrl!, uid: global.uid!);
  }

  // for Pomodoro
  set counterTaskGroup(TaskGroup taskGroup) {
    currentTaskGroup = taskGroup;
    currentTask = null;
    notifyListeners();
  }

  set counterTask(Task? task) {
    currentTask = task;
    notifyListeners();
  }

  set focusState(FocusState focusState) {
    counter.setFocusState(focusState);
    timer?.cancel();
    notifyListeners();
  }

  FocusState get focusState => counter.focusState;

  void startCountDown() {
    counter.isfinished = false;
    timer = Timer.periodic(const Duration(milliseconds: 1), (timer) async {
      if (counter.isfinished) {
        timer.cancel();

        if (counter.focusState != FocusState.pomodoro && currentTask != null) {
          final request = UpdateTaskRequest(id: currentTask!.id, finishTime: currentTask!.finishTime + 1);
          currentTask = await api.updateTask(request);
        }
      } else {
        counter.countDownOnce();
      }

      notifyListeners();
    });
  }

  void stopCountDown() {
    counter.state = RunningState.paused;
    timer?.cancel();
    notifyListeners();
  }

  void setTimes({
    int? pomodoroTime,
    int? shortBreakTime,
    int? longBreakTime,
    int? longBreakInterval
  }) {
    if (pomodoroTime != null) {
      counter.pomodoroTime = pomodoroTime;
    }

    if (shortBreakTime != null) {
      counter.shortBreakTime = shortBreakTime;
    }

    if (longBreakTime != null) {
      counter.longBreakTime = longBreakTime;
    }

    if (longBreakInterval != null) {
      counter.longBreakInterval = longBreakInterval;
    }

    counter.setFocusState(counter.focusState);
    notifyListeners();
  }

  void resetTimes() {
    counter = Counter(pomodoroTime: todoListSettings["state.todolist.pomodoro-time"], shortBreakTime: todoListSettings["state.todolist.short-break-time"], longBreakTime: todoListSettings["state.todolist.long-break-time"], longBreakInterval: todoListSettings["state.todolist.long-break-interval"]);
    notifyListeners();
  }

  void clearActPomodoros() {
    final futures = currentTaskGroup?.tasks.map((element) async {
      final request = UpdateTaskRequest(id: element.id, finishTime: 0);
      await updateTaskAtCurrent(request);

      element.finishTime = 0;
    }).toList() ?? [];

    Future.wait(futures);

    notifyListeners();
  }

  String imageUrl(int id) => join(imageApi.url, "download", id.toString());

  // Priority
  Future<void> insertPriority(PostPriorityRequest request) async {
    Priority priority = await api.insertPriority(request);
    priorities.add(priority);

    notifyListeners();
  }

  Future<void> deletePriority(int id) async {
    await api.deletePriority(id);
    priorities.removeWhere((element) => element.id == id);

    notifyListeners();
  }

  Future<void> updatePriority(UpdatePriorityRequest request) async {
    Priority priority = await api.updatePriority(request);
    final index = priorities.indexWhere((element) => element.id == request.id);
    priorities[index] = priority;

    notifyListeners();
  }

  // Tag
  Future<void> insertTag(PostTagRequest request) async {
    Tag tag = await api.insertTag(request);
    tags.add(tag);
    notifyListeners();
  }

  Future<void> deleteTag(int id) async {
    await api.deleteTag(id);
    tags.removeWhere((element) => element.id == id);

    notifyListeners();
  }

  Future<void> updateTag(UpdateTagRequest request) async {
    Tag tag = await api.updateTag(request);
    final index = tags.indexWhere((element) => element.id == request.id);
    tags[index] = tag;
  }

  // Task
  Future<void> insertTask(PostTaskRequest request) async {
    Task task = await api.insertTask(request);
    int parentid = task.parentid;
    int indexOfTaskGroups = taskGroups.indexWhere((element) => element.id == parentid);
    taskGroups[indexOfTaskGroups].tasks.insert(0, task);

    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    Task task = await api.findTask(id);
    await api.deleteTask(id);
    int parentid = task.parentid;

    final taskGroup = taskGroups.firstWhere((element) => element.id == parentid);
    final index = taskGroup.tasks.indexWhere((element) => element.id == id);
    taskGroup.tasks.removeAt(index);

    if (task.id == currentTask?.id) {
      setCurrentTask(null);
    }

    notifyListeners();
  }

  Future<void> updateTaskAtCurrent(UpdateTaskRequest request) async {
    Task task = await api.updateTask(request);
    int parentid = task.parentid;

    final taskGroup = taskGroups.firstWhere((element) => element.id == parentid);
    final index = taskGroup.tasks.indexWhere((element) => element.id == task.id);
    taskGroup.tasks[index] = task;
    currentTask!.copyFrom(task);

    notifyListeners();
  }

  Future<void> insertTagAtCurrent(int tagid) async {
    final request = PostTaskTagRequest(taskid: currentTask!.id, tagid: tagid);
    await api.insertTaskTag(request);
    currentTask!.tags.add(tags.firstWhere((element) => element.id == tagid));

    notifyListeners();
  }

  Future<void> removeDeadline(int id) async {
    await api.removeDeadline(id);
    currentTask!.deadline = null;
    notifyListeners();
  }

  Future<void> removeNotifyTime(int id) async {
    await api.removeNotifyTime(id);
    currentTask!.notifyTime = null;
    notifyListeners();
  }

  Future<void> removeTagAtCurrentTask(int tagid) async {
    await api.removeTag(currentTask!.id, tagid);
    currentTask!.tags.removeWhere((element) => element.id == tagid);
    notifyListeners();
  }

  Future<void> removeNoteAtCurrentTask() async {
    await api.removeNote(currentTask!.id);
    currentTask!.note = null;

    notifyListeners();
  }

  void setCurrentTask(Task? task) {
    currentTask = task;
    currentTaskNotifier.value = task;
    notifyListeners();
  }

  Future<void> reorderTask(ReorderRequest request, Task from, Task? to) async {
    await api.reorderTask(request);
    // ATTENTION , when reordering Task, the parentid is not null always
    if (to == null) {
      await reorderTask0(request, from);
    } else {
      await reorderTask1(request, from, to);
    }

    notifyListeners();
  }

  Future<void> reorderTask0(ReorderRequest request, Task from) async {
    int reorderAfter = 0;
    final oldList = taskGroups.firstWhere((element) => element.id == from.parentid);
    oldList.tasks.removeWhere((element) => element.id == from.id);
    final newList = taskGroups.firstWhere((element) => element.id == request.parentid);

    if (request.parentid == from.parentid) {
        oldList.tasks
            .where((element) => element.index >= reorderAfter && element.index < from.index)
            .forEach((element) => element.index += 1);

    } else {

      oldList.tasks.where((element) => element.index > from.index)
          .forEach((element) => element.index -= 1);

      newList.tasks
          .where((element) => element.index >= reorderAfter + 1)
          .forEach((element) => element.index += 1);
    }

    from.index = reorderAfter;
    newList.tasks.insert(0, from);
    if (request.parentid != null) {
      from.parentid = request.parentid!;
    }
  }

  Future<void> reorderTask1(ReorderRequest request, Task from, Task to) async {
    final oldList = taskGroups.firstWhere((element) => element.id == from.parentid);
    oldList.tasks.removeWhere((element) => element.id == from.id);

    final newList = taskGroups.firstWhere((element) => element.id == to.parentid);

    int reorderAfter = request.reorderAfter;

    if (from.parentid == to.parentid) {
      if (from.index < reorderAfter) {
        oldList.tasks
            .where((element) => element.index <= reorderAfter && element.index > from.index)
            .forEach((element) => element.index -= 1);
      } else if (from.index > reorderAfter) {
        oldList.tasks
            .where((element) => element.index >= reorderAfter && element.index < from.index)
            .forEach((element) => element.index += 1);
      } else {
        // nothing to do
      }
    } else {
      oldList.tasks
          .where((element) => element.index > from.index)
          .forEach((element) => element.index -= 1);

      newList.tasks
          .where((element) => element.index >= reorderAfter + 1)
          .forEach((element) => element.index += 1);
    }

    if (from.parentid != to.parentid) {
      from.parentid = request.parentid!;
      from.index = reorderAfter + 1;

      // fixed
      if (reorderAfter + 1 > newList.tasks.length - 1) {
        newList.tasks.add(from);
      } else {
        newList.tasks.insert(reorderAfter + 1, from);
      }
    } else {
      from.index = reorderAfter;
      newList.tasks.insert(reorderAfter, from);
    }

  }

  // TaskGroup
  Future<void> insertTaskGroup(PostTaskGroupRequest request) async {
    TaskGroup taskGroup = await api.insertTaskGroup(request);
    taskGroups.add(taskGroup);

    notifyListeners();
  }

  Future<void> deleteTaskGroup(int id) async {
    await api.deleteTaskGroup(id);
    taskGroups.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> updateTaskGroup(UpdateTaskGroupRequest request) async {
    TaskGroup taskGroup = await api.updateTaskGroup(request);
    final index = taskGroups.indexWhere((element) => element.id == taskGroup.id);
    taskGroups[index] = taskGroup;

    notifyListeners();
  }

  Future<void> reorderTaskGroup(ReorderRequest request) async {
    await api.reorderTaskGroup(request);
    int index = taskGroups.indexWhere((element) => element.id == request.id);
    final item = taskGroups.removeAt(index);
    taskGroups.insert(request.reorderAfter, item);

    if (currentTask!.index < request.reorderAfter) {
      taskGroups.where((element) => element.index <= request.reorderAfter && element.index > currentTask!.index)
          .forEach((element) {
            element.index -= 1;
      });
    } else if (currentTask!.index > request.reorderAfter) {
      taskGroups.where((element) => element.index >= request.reorderAfter && element.index < currentTask!.index)
          .forEach((element) {
        element.index += 1;
      });
    } else {

    }

    item.index = request.reorderAfter;
    notifyListeners();
  }

  Future<void> insertTaskProject(PostTaskProjectRequest request) async {
    TaskProject taskProject = await api.insertTaskProject(request);
    taskProjects.insert(0, taskProject);

    notifyListeners();
  }

  Future<void> deleteTaskProject(int id) async {
    await api.deleteTaskProject(id);
    taskProjects.removeWhere((element) => element.id == id);

    notifyListeners();
  }

  Future<void> updateTaskProject(UpdateTaskProjectRequest request) async {
    TaskProject taskProject = await api.updateTaskProject(request);
    final index = taskProjects.indexWhere((element) => element.id == taskProject.id);
    taskProjects[index] = taskProject;

    notifyListeners();
  }

  Future<bool> loadTaskProjects() async {
    taskProjects = await api.findTaskProjects();
    return true;
  }

  Future<void> setCurrentTaskProject(TaskProject taskProject) async {
    currentTaskProject = taskProject;
    taskGroups = await api.findTaskGroups(taskProject.id);
    tags = await api.findTags(taskProject.id);
    notifyListeners();
  }

  // SubTask
  Future<void> insertSubTaskAtCurrentTask(PostSubTaskRequest request) async {
    SubTask subtask = await api.insertSubTask(request);
    currentTask!.subtasks.add(subtask);
    notifyListeners();
  }

  Future<void> updateSubTaskAtCurrentTask(UpdateSubTaskRequest request) async {
    SubTask subtask = await api.updateSubTask(request);
    int index = currentTask!.subtasks.indexWhere((element) => element.id == subtask.id);
    currentTask!.subtasks[index] = subtask;

    notifyListeners();
  }

  Future<void> deleteSubTaskAtCurrentTask(int id) async {
    await api.deleteSubTask(id);
    currentTask!.subtasks.removeWhere((element) => element.id == id);

    notifyListeners();
  }

  // other
  void setCurrentTaskGroup(TaskGroup? taskGroup) {
    currentTaskGroup = taskGroup;
    currentTask = null;
  }

  // image
  Future<ImageItem> insertImage(MultipartFile file) async {
    return await imageApi.insertOne(file);
  }
}
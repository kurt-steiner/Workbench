import 'package:flutter/material.dart';
import 'package:frontend/model/enumeration.dart';
import 'package:frontend/util/extensions.dart';


class Priority {
  int id;
  String name;
  int order;
  int parentid;
  PriorityColor color;

  Color get trueColor => priorityColors[color]!;

  Priority({
    required this.id,
    required this.name,
    required this.order,
    required this.parentid,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "order": order,
      "parentid": parentid,
      "color": color.toString()
    };
  }

  factory Priority.fromJson(Map<String, dynamic> json) {
    return Priority(
      id: json["id"],
      name: json["name"],
      order: json["order"],
      parentid: json["parentid"],
      color: priorityMap[json["color"]]!
    );
  }
}

class SubTask {
   int id;
   int index;
   String name;
   bool isdone;
   int parentid;

  SubTask({
    required this.id,
    required this.index,
    required this.name,
    required this.isdone,
    required this.parentid
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json["id"],
      index: json["index"],
      name: json["name"],
      isdone: json["isdone"],
      parentid: json["parentid"]
    );
  }
}

class Tag {
   int id;
   String name;
   int parentid;
   Color color;

  Tag({
    required this.id,
    required this.name,
    required this.parentid,
    required this.color
  });

  @override
  bool operator ==(Object other) {
    if (other.runtimeType is! Tag) {
      return false;
    }

    Tag otherTag = other as Tag;
    return id == otherTag.id;
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json["id"],
      name: json["name"],
      parentid: json["parentid"],
      color: tagColors[tagMap[json["color"]]!]!
    );
  }
}

class Task {
   int id;
   int index;
   String name;
   bool isdone;
   Priority priority;
   String? note;
   List<SubTask> subtasks;
   int expectTime;
   int finishTime;
   DateTime? deadline;
   DateTime? notifyTime;
   List<Tag> tags;
   int parentid;
   DateTime createTime;
   DateTime updateTime;

  Task({
    required this.id,
    required this.index,
    required this.name,
    required this.isdone,
    required this.priority,
    this.note,
    required this.subtasks,
    required this.expectTime,
    required this.finishTime,
    this.deadline,
    this.notifyTime,
    required this.tags,
    required this.parentid,
    required this.createTime,
    required this.updateTime
  });

  void copyFrom(Task task) {
    index = task.index;
    name = task.name;
    isdone = task.isdone;
    priority = task.priority;
    note = task.note;
    subtasks = task.subtasks;
    expectTime = task.expectTime;
    finishTime = task.finishTime;
    deadline = task.deadline;
    notifyTime = task.notifyTime;
    tags = task.tags;
    parentid = task.parentid;
    createTime = task.createTime;
    updateTime = task.updateTime;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json["id"],
      index: json["index"],
      name: json["name"],
      isdone: json["isdone"],
      priority: Priority.fromJson(json["priority"]),
      notifyTime: json["notifyTime"] == null ? null : DateTime.parse(json["notifyTime"]),
      deadline: json["deadline"] == null ? null : DateTime.parse(json["deadline"]),
      note: json["note"],
      subtasks: (json["subtasks"] as List<dynamic>).map<SubTask>((e) => SubTask.fromJson(e)).toList(),
      expectTime: json["expectTime"],
      finishTime: json["finishTime"],
      tags: (json["tags"] as List<dynamic>).map<Tag>((e) => Tag.fromJson(e)).toList(),
      parentid: json["parentid"],
      createTime: DateTime.parse(json["createTime"]),
      updateTime: DateTime.parse(json["updateTime"])
    );
  }
}

class TaskGroup {
   int id;
   int index;
   String name;
   List<Task> tasks;
   DateTime createTime;
   DateTime updateTime;
   int parentid;

   TaskGroup({
     required this.id,
     required this.index,
     required this.name,
     required this.tasks,
     required this.createTime,
     required this.updateTime,
     required this.parentid
   });

   void copyFrom(TaskGroup taskGroup) {
     id = taskGroup.id;
     index = taskGroup.index;
     name = taskGroup.name;
     tasks = taskGroup.tasks;
     createTime = taskGroup.createTime;
     updateTime = taskGroup.updateTime;
     parentid = taskGroup.parentid;
   }

   factory TaskGroup.fromJson(Map<String, dynamic> json) {
     return TaskGroup(
         id: json["id"],
         index: json["index"],
         name: json["name"],
         tasks: (json["tasks"] as List<dynamic>).map((e) => Task.fromJson(e)).toList(),
         createTime: DateTime.parse(json["createTime"]),
         updateTime: DateTime.parse(json["updateTime"]),
         parentid: json["parentid"]
     );
   }
}

class TaskProject {
   int id;
   int index;
   String name;
   int? avatarid;
   String? profile;
   DateTime createTime;
   DateTime updateTime;

  TaskProject({
    required this.id,
    required this.index,
    required this.name,
    this.avatarid,
    this.profile,
    required this.createTime,
    required this.updateTime
  });

  @override
  String toString() {
    return "$id-"
        "$index-"
        "$name-"
        "$avatarid-"
        "$profile-"
        "${createTime.toIso8601String()}-"
        "${updateTime.toIso8601String()}";
  }

  factory TaskProject.fromJson(Map<String, dynamic> json) {
    return TaskProject(
      id: json["id"],
      index: json["index"],
      name: json["name"],
      avatarid: json["avatarid"],
      profile: json["profile"],
      createTime: DateTime.parse(json["createTime"]),
      updateTime: DateTime.parse(json["updateTime"])
    );
  }
}
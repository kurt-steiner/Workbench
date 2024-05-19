import 'package:frontend/model/daily-attendance.dart';
import 'package:frontend/model/enumeration.dart';
import 'package:frontend/util/extensions.dart';

class PostIconImageRequest {
  int entryId;
  int backGroundId;
  FlatUIColor backGroundColor;

  PostIconImageRequest({
    required this.entryId,
    required this.backGroundId,
    required this.backGroundColor
  });

  Map<String, dynamic> toJson() {
    return {
      "entryId": entryId,
      "backGroundId": backGroundId,
      "backGroundColor": backGroundColor.toEnumString()
    };
  }
}

class PostIconWordRequest {
  String word;
  FlatUIColor color;

  PostIconWordRequest({
    required this.word,
    required this.color
  });

  Map<String, dynamic> toJson() {
    return {
      "word": word,
      "color": color.toEnumString()
    };
  }
}

class PostTaskRequest {
  String name;
  Icon icon;
  String encouragement;
  Frequency frequency;
  Goal goal;
  KeepDays keepdays;
  Group group;
  DateTime startTime;
  List<NotifyTime> notifyTimes;

  PostTaskRequest({
    required this.name,
    required this.icon,
    required this.encouragement,
    required this.frequency,
    required this.goal,
    required this.keepdays,
    required this.group,
    required this.startTime,
    required this.notifyTimes
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "icon": icon.toJson(),
      "encouragement": encouragement,
      "frequency": frequency.toJson(),
      "goal": goal.toJson(),
      "keepdays": keepdays.toJson(),
      "group": group.stringValue(),
      "startTime": startTime.toIsoString(),
      "notifyTimes": notifyTimes.map<Map<String, dynamic>>((e) => e.toJson()).toList()
    };
  }
}

class UpdateArchiveTaskRequest {
  int id;
  bool isarchive;

  UpdateArchiveTaskRequest({
    required this.id,
    required this.isarchive
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "isarchive": isarchive
    };
  }
}

class UpdateProgressRequest {
  int id;
  Progress progress;

  UpdateProgressRequest({
    required this.id,
    required this.progress
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "progress": progress.toJson()
    };
  }
}

class UpdateTaskRequest {
  int id;
  String? name;
  Icon? icon;
  String? encouragement;
  Frequency? frequency;
  Goal? goal;
  DateTime? startTime;
  KeepDays? keepdays;
  Group? group;
  List<NotifyTime>? notifyTimes;

  UpdateTaskRequest({
    required this.id,
    this.name,
    this.icon,
    this.encouragement,
    this.frequency,
    this.goal,
    this.startTime,
    this.keepdays,
    this.group,
    this.notifyTimes
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "icon": icon?.toJson(),
      "encouragement": encouragement,
      "frequency": frequency?.toJson(),
      "goal": goal?.toJson(),
      "startTime": startTime?.toIsoString(),
      "keepdays": keepdays?.toJson(),
      "group": group?.toString(),
      "notifyTimes": notifyTimes?.map<Map<String, dynamic>>((e) => e.toJson()).toList()
    };
  }

  factory UpdateTaskRequest.fromObject(Task task) {
    return UpdateTaskRequest(
        id: task.id,
        name: task.name.trim(),
        icon: task.icon,
        encouragement: task.encouragement.trim(),
        frequency: task.frequency,
        goal: task.goal,
        startTime: task.startTime,
        keepdays: task.keepdays,
        group: task.group,
        notifyTimes: task.notifyTimes
    );
  }
}
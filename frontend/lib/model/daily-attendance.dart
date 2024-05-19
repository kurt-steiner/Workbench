import 'package:flutter/material.dart' show Color, Widget;
import 'package:frontend/model/enumeration.dart';
import 'package:frontend/util/extensions.dart';

sealed class Frequency {
  Map<String, dynamic> toJson();

  static fromJson(Map<String, dynamic> json) {
    switch (json["type"]) {
      case "days": return Days.fromJson(json);
      case "count-in-week": return CountInWeek.fromJson(json);
      case "interval": return Interval.fromJson(json);
      default: throw Exception("no such frequency type");
    }
  }
}

class Days extends Frequency {
  List<String> weekdays;
  Days({required this.weekdays});

  factory Days.fromJson(Map<String, dynamic> json) {
    return Days(weekdays: json["weekdays"].cast<String>());
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "days",
      "weekdays": weekdays
    };
  }
}

class CountInWeek extends Frequency {
  int count;
  CountInWeek({required this.count});

  factory CountInWeek.fromJson(Map<String, dynamic> json) {
    return CountInWeek(count: json["count"]);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "count-in-week",
      "count": count
    };
  }
}

class Interval extends Frequency {
  int count;
  Interval({required this.count});

  factory Interval.fromJson(Map<String, dynamic> json) {
    return Interval(count: json["count"]);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "interval",
      "count": count
    };
  }
}

sealed class Goal {
  Map<String, dynamic> toJson();

  static Goal fromJson(Map<String, dynamic> json) {
    switch (json["type"]) {
      case "current-day": return CurrentDay.fromJson(json);
      case "amount": return Amount.fromJson(json);
      default: throw Exception("no such goal type");
    }
  }
}

class CurrentDay extends Goal {
  CurrentDay();

  factory CurrentDay.fromJson(Map<String, dynamic> _json) {
    return CurrentDay();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "current-day"
    };
  }
}

class Amount extends Goal {
  int total;
  String unit;
  int eachAmount;
  Amount({required this.total, required this.unit, required this.eachAmount});

  factory Amount.fromJson(Map<String, dynamic> json) {
    return Amount(
      total: json["total"],
      unit: json["unit"],
      eachAmount: json["eachAmount"]
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "amount",
      "total": total,
      "unit": unit,
      "eachAmount": eachAmount
    };
  }

}

const _groupMap = {
  Group.noon: 0,
  Group.afternoon: 1,
  Group.night: 2,
  Group.other: 3
};

enum Group implements Comparable<Group> {
  noon,
  afternoon,
  night,
  other;

  @override
  int compareTo(Group other) {
    int key1 = _groupMap[this]!;
    int key2 = _groupMap[other]!;

    return key1.compareTo(key2);
  }


}

extension ToStringExtension on Group {
  String stringValue() {
    switch (this) {
      case Group.noon: return "Noon";
      case Group.afternoon: return "Afternoon";
      case Group.night: return "Night";
      default: return "Other";
    }
  }

  String stringChinese() {
    switch (this) {
      case Group.noon: return "上午";
      case Group.afternoon: return "下午";
      case Group.night: return "晚上";
      case Group.other: return "其他";
    }
  }
}

sealed class Icon {
  Map<String, dynamic> toJson();

  static Icon fromJson(Map<String, dynamic> json) {
    switch (json["type"]) {
      case "image": return Image.fromJson(json);
      case "word": return Word.fromJson(json);
      default: throw Exception("no such icon type");
    }
  }
}

class Image extends Icon {
  int entryId;
  int backGroundId;
  FlatUIColor backGroundColor;

  Image({required this.entryId, required this.backGroundId, required this.backGroundColor});

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      entryId: json["entryId"],
      backGroundId: json["backGroundId"],
      backGroundColor: flatUIMap[json["backGroundColor"]]!
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "image",
      "entryId": entryId,
      "backGroundId": backGroundId,
      "backGroundColor": backGroundColor.toEnumString()
    };
  }
}

class Word extends Icon {
  String char;
  FlatUIColor color;

  Word({required this.char, required this.color}): assert(char.length == 1);

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      char: json["char"],
      color: flatUIMap[json["color"]]!
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "word",
      "char": char,
      "color": color.toEnumString()
    };
  }
}

sealed class KeepDays {
  Map<String, dynamic> toJson();
  KeepDays copy();

  static KeepDays fromJson(Map<String, dynamic> json) {
    switch (json["type"]) {
      case "forever": return Forever.fromJson(json);
      case "manual": return Manual.fromJson(json);
      default: throw Exception("no such keepdays type");
    }
  }
}

class Forever extends KeepDays {
  Forever();

  factory Forever.fromJson(Map<String, dynamic> _json) {
    return Forever();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "forever"
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return "永远";
  }

  @override
  KeepDays copy() {
    return Forever();
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is Forever;
  }
}

class Manual extends KeepDays {
  int days;

  Manual({required this.days});

  factory Manual.fromJson(Map<String, dynamic> json) {
    return Manual(days: json["days"]);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "manual",
      "days": days
    };
  }

  @override
  KeepDays copy() {
    // TODO: implement copy
    return Manual(days: days);
  }

  @override
  String toString() {
    // TODO: implement toString
    return "$days天";
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if (other is! Manual) {
      return false;
    }

    return days == other.days;
  }
}

class NotifyTime {
  int hour;
  int minute;

  NotifyTime({required this.hour, required this.minute});

  factory NotifyTime.fromJson(Map<String, dynamic> json) {
    return NotifyTime(hour: json["hour"], minute: json["minute"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "hour": hour,
      "minute": minute
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }
}

sealed class Progress {
  Map<String, dynamic> toJson();

  static Progress fromJson(Map<String, dynamic> json) {
    switch (json["type"]) {
      case "not-scheduled": return NotScheduled.fromJson(json);
      case "ready": return Ready.fromJson(json);
      case "done": return Done.fromJson(json);
      case "doing": return Doing.fromJson(json);
      default: throw Exception("no such progress type");
    }
  }
}

class NotScheduled extends Progress {
  NotScheduled();

  factory NotScheduled.fromJson(Map<String, dynamic> _json) {
    return NotScheduled();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "not-scheduled"
    };
  }
}

class Ready extends Progress {
  Ready();

  factory Ready.fromJson(Map<String, dynamic> _json) {
    return Ready();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "ready"
    };
  }
}

class Done extends Progress {
  Done();

  factory Done.fromJson(Map<String, dynamic> _json) {
    return Done();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "done"
    };
  }
}

class Doing extends Progress {
  int total;
  String unit;
  int amount;

  Doing({required this.total, required this.unit, required this.amount});

  factory Doing.fromJson(Map<String, dynamic> json) {
    return Doing(
      total: json["total"],
      unit: json["unit"],
      amount: json["amount"]
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "doing",
      "total": total,
      "unit": unit,
      "amount": amount
    };
  }
}

class Task implements Comparable<Task> {
  int id;
  String name;
  Icon icon;
  String encouragement;
  Frequency frequency;
  Goal goal;
  DateTime startTime;
  KeepDays keepdays;
  Group group;
  List<NotifyTime> notifyTimes;
  Progress progress;
  bool isarchived;
  int consecutiveDays;
  int persistenceDays;

  Task({
    required this.id,
    required this.name,
    required this.icon,
    required this.encouragement,
    required this.frequency,
    required this.goal,
    required this.group,
    required this.startTime,
    required this.keepdays,
    required this.notifyTimes,
    required this.progress,
    required this.isarchived,
    required this.consecutiveDays,
    required this.persistenceDays
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json["id"],
      name: json["name"],
      icon: Icon.fromJson(json["icon"]),
      encouragement: json["encouragement"],
      frequency: Frequency.fromJson(json["frequency"]),
      goal: Goal.fromJson(json["goal"]),
      group: groupFromValue(json["group"]),
      startTime: DateTime.parse(json["startTime"]),
      keepdays: KeepDays.fromJson(json["keepdays"]),
      notifyTimes: (json["notifyTimes"] as List<dynamic>).map<NotifyTime>((e) => NotifyTime.fromJson(e)).toList(),
      progress: Progress.fromJson(json["progress"]),
      isarchived: json["isarchived"],
      consecutiveDays: json["consecutiveDays"],
      persistenceDays: json["persistenceDays"]
    );
  }

  Task copy() {
    return Task(
        id: id,
        name: name,
        icon: icon,
        encouragement: encouragement,
        frequency: frequency,
        goal: goal,
        startTime: startTime,
        keepdays: keepdays,
        group: group,
        notifyTimes: notifyTimes,
        progress: progress,
        isarchived: isarchived,
        persistenceDays: persistenceDays,
        consecutiveDays: consecutiveDays
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "icon": icon.toJson(),
      "encouragement": encouragement,
      "frequency": frequency.toJson(),
      "goal": goal.toJson(),
      "group": group.toString(),
      "startTime": startTime.toIsoString(),
      "keepdays": keepdays.toJson(),
      "notifyTimes": notifyTimes.map<Map<String, dynamic>>((e) => e.toJson()).toList(),
      "progress": progress.toJson(),
      "isarchived": isarchived,
      "consecutiveDays": consecutiveDays,
      "persistenceDays": persistenceDays
    };
  }

  static Group groupFromValue(String value) {
    switch (value) {
      case "Noon": return Group.noon;
      case "Afternoon": return Group.afternoon;
      case "Night": return Group.night;
      case "Other": return Group.other;
      default: throw Exception("no such group type");
    }
  }

  @override
  int compareTo(Task other) {
    // TODO: implement compareTo
    return id.compareTo(other.id);
  }
}

enum IconMode {
  image,
  word
}

class ImageCompose {
  Widget? entry;
  Widget? background;

  ImageCompose({this.entry, this.background});

  ImageCompose copyWith({Widget? entry, Widget? background}) {
    return ImageCompose(
        entry: entry ?? this.entry,
        background: background ?? this.background
    );
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if (other is! ImageCompose) {
      return false;
    }

    final other1 = other as ImageCompose;
    return entry == other1.entry && background == other1.background;
  }
}

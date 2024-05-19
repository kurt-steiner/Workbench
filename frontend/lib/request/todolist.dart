import 'package:frontend/model/enumeration.dart';
import 'package:frontend/model/todolist.dart';

class PostPriorityRequest {
  String name;
  int order;
  int parentid;
  PriorityColor color;

  PostPriorityRequest({
    required this.name,
    required this.order,
    required this.parentid,
    required this.color
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "order": order,
      "parentid": parentid,
      "color": color.toEnumString()
    };
  }
}

class PostSubTaskRequest {
   int parentid;
   String name;

  PostSubTaskRequest({
    required this.parentid,
    required this.name
  });

  Map<String, dynamic> toJson() {
    return {
      "parentid": parentid,
      "name": name
    };
  }
}

class PostTagRequest {
   String name;
   int parentid;
   FlatUIColor color;

  PostTagRequest({
    required this.name,
    required this.parentid,
    required this.color
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "parentid": parentid,
      "color": color.toEnumString()
    };
  }
}

class PostTaskGroupRequest {
   int parentid;
   String name;

  PostTaskGroupRequest({
    required this.parentid,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      "parentid": parentid,
      "name": name,
    };
  }
}

class PostTaskProjectRequest {
   String name;
   int? avatarid;
   String? profile;

  PostTaskProjectRequest({
    required this.name,
    this.avatarid,
    this.profile
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "avatarid": avatarid,
      "profile": profile
    };
  }
}

class PostTaskRequest {
   String name;
   int parentid;
   String? note;
   Priority? priority;
   DateTime? deadline;
   DateTime? notifyTime;
   int expectTime;

  PostTaskRequest({
    required this.name,
    required this.parentid,
    this.note,
    this.priority,
    this.deadline,
    this.notifyTime,
    required this.expectTime
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "parentid": parentid,
      "note": note,
      "priority": priority?.toJson(),
      "deadline": deadline?.toIso8601String(),
      "notifyTime": notifyTime?.toIso8601String(),
      "expectTime": expectTime
    };
  }
}

class PostTaskTagRequest {
   int taskid;
   int tagid;

  PostTaskTagRequest({
    required this.taskid,
    required this.tagid
  });

  Map<String, dynamic> toJson() {
    return {
      "taskid": taskid,
      "tagid": tagid
    };
  }
}

class ReorderRequest {
   int id;
   int reorderAfter;
   int? parentid;

  ReorderRequest({
    required this.id,
    required this.reorderAfter,
    this.parentid
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "reorderAfter": reorderAfter,
      "parentid": parentid
    };
  }
}

class UpdatePriorityRequest {
   int id;
   String? name;
   int? order;

  UpdatePriorityRequest({
    required this.id,
    this.name,
    this.order
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "order": order
    };
  }
}

class UpdateSubTaskRequest {
   int id;
   String? name;
   bool? isdone;

  UpdateSubTaskRequest({
    required this.id,
    this.name,
    this.isdone
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "isdone": isdone
    };
  }
}

class UpdateTagRequest {
   int id;
   String name;

  UpdateTagRequest({
    required this.id,
    required this.name
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name
    };
  }
}

class UpdateTaskGroupRequest {
   int id;
   String name;

  UpdateTaskGroupRequest({
    required this.id,
    required this.name
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name
    };
  }
}

class UpdateTaskProjectRequest {
   int id;
   String? name;
   int? avatarid;
   String? profile;

  UpdateTaskProjectRequest({
    required this.id,
    required this.name,
    required this.avatarid,
    required this.profile
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "avatarid": avatarid,
      "profile": profile
    };
  }
}

class UpdateTaskRequest {
   int id;
   String? name;
   bool? isdone;
   DateTime? deadline;
   DateTime? notifyTime;
   String? note;
   Priority? priority;
   int? expectTime;
   int? finishTime;
   int? parentid;

  UpdateTaskRequest({
    required this.id,
    this.name,
    this.isdone,
    this.deadline,
    this.notifyTime,
    this.note,
    this.priority,
    this.expectTime,
    this.finishTime,
    this.parentid
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "isdone": isdone,
      "deadline": deadline?.toIso8601String(),
      "notifyTime": notifyTime?.toIso8601String(),
      "note": note,
      "priority": priority?.toJson(),
      "expectTime": expectTime,
      "finishTime": finishTime,
      "parentid": parentid
    };
  }
}
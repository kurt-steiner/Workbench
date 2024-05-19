import 'package:dio/dio.dart';
import 'package:frontend/model/daily-attendance.dart';
import 'package:frontend/request/daily-attendance.dart';
import 'package:path/path.dart' show join;

class DailyAttendanceApi {
  static Map<int, String> weekDayMap = {
    DateTime.monday: "MONDAY",
    DateTime.tuesday: "TUESDAY",
    DateTime.wednesday: "WEDNESDAY",
    DateTime.thursday: "THURSDAY",
    DateTime.friday: "FRIDAY",
    DateTime.saturday: "SATURDAY",
    DateTime.sunday: "SUNDAY"
  };

  static Map<String, int> weekDayIndex = {
    "MONDAY": 0,
    "TUESDAY": 1,
    "WEDNESDAY": 2,
    "THURSDAY": 3,
    "FRIDAY": 4,
    "SATURDAY": 5,
    "SUNDAY": 6
  };

  final String baseUrl;
  late Dio instance;
  String uid;
  String get url => join(baseUrl, "daily-attendance");

  Map<String, String> get headers => {
    "uid": uid
  };

  DailyAttendanceApi({required this.baseUrl, required this.uid}) {
    instance = Dio(BaseOptions(
        baseUrl: url,
        headers: headers
    ));
  }

  Future<Task> insertTask(PostTaskRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.post("", data: request.toJson());
    return Task.fromJson(response.data!["data"]);
  }

  Future<Task> updateTask(UpdateTaskRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.put("", data: request.toJson());
    return Task.fromJson(response.data!["data"]);
  }

  Future<void> updateArchive(UpdateArchiveTaskRequest request) async {
    await instance.put("/archive", data: request.toJson());
  }

  Future<Task> updateProgress(UpdateProgressRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.put("/progress", data: request.toJson());
    return Task.fromJson(response.data!["data"]);
  }

  Future<void> deleteTask(int id) async {
    await instance.delete("/${id}");
  }

  Future<Task> findTask(int id) async {
    final Response<Map<String, dynamic>> response = await instance.get("/${id}");
    return Task.fromJson(response.data!["data"]);
  }

  Future<Map<String, List<Task>>> findAllOfLatest7Days() async {
    final Response<Map<String, dynamic>> response = await instance.get("/current-7");
    final data = response.data!["data"] as Map<String, dynamic>;

    Map<String, List<Task>> map = data.map((key, value) {
      return MapEntry(
        key,
        value.map<Task>((e) => Task.fromJson(e)).toList()
      );
    });

    final dayOfWeekRecord = Map<String, DateTime>();
    final currentDay = DateTime.now();
    final end = currentDay.add(const Duration(days: 1));
    final past6DateTime = currentDay.subtract(const Duration(days: 6));
    DateTime time = past6DateTime;

    while (time.isBefore(end)) {
      dayOfWeekRecord[weekDayMap[time.weekday]!] = time;
      time = time.add(const Duration(days: 1));
    }

    return Map.fromEntries(
      map.entries.toList()..sort((left, right) => dayOfWeekRecord[left.key]!.compareTo(dayOfWeekRecord[right.key]!))
    );
  }

  Future<List<Task>> findAllOfCurrentDay() async {
    final Response<Map<String, dynamic>> response = await instance.get("/current-day");
    return (response.data!["data"] as List<dynamic>).map<Task>((e) => Task.fromJson(e)).toList();
  }

  Future<Task> resetToday(int id) async {
    final Response<Map<String, dynamic>> response = await instance.put("/reset/$id");
    return Task.fromJson(response.data!["data"]);
  }

  Future<Map<Task, List<Progress>>> statisticsWeekly(int offset) async {
    assert(offset <= 0);

    final Response<Map<String, dynamic>> response = await instance.get("/statistics/week", queryParameters: {
      "offset": offset
    });
    final Map<String, dynamic> data = response.data!["data"];
    final result = Map<Task, List<Progress>>();

    for (final entry in data.entries) {
      final id = int.parse(entry.key);
      final task = await findTask(id);
      result[task] = List<Progress>.generate(7, (index) => NotScheduled());

      for (final entry1 in entry.value.entries) {
        final dayOfWeek = entry1.key;
        final progress = Progress.fromJson(entry1.value);
        final index = weekDayIndex[dayOfWeek]!;
        result[task]![index] = progress;
      }
    }

    return result;
  }

  Future<Map<Task, List<Progress>>> statisticsMonthly(int offset) async {
    assert(offset <= 0);

    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month - offset.abs() + 1, 1).subtract(const Duration(days: 1));
    final numberOfDays = endOfMonth.day;

    final Response<Map<String, dynamic>> response = await instance.get("/statistics/month", queryParameters: {
      "offset": offset
    });

    final Map<String, dynamic> data = response.data!["data"];
    final result = Map<Task, List<Progress>>();

    for (final entry in data.entries) {
      final id = int.parse(entry.key);
      final task = await findTask(id);
      result[task] = List<Progress>.generate(numberOfDays, (index) => NotScheduled());

      for (final entry1 in entry.value.entries) {
        final dayOfMonth = int.parse(entry1.key);
        final progress = Progress.fromJson(entry1.value);
        final index = dayOfMonth - 1;
        result[task]![index] = progress;
      }
    }

    return result;
  }

  Future<List<Task>> findAllTasks(bool isarchive) async {
    final Response<Map<String, dynamic>> response = await instance.get("", queryParameters: {
      "isarchived": isarchive
    });

    return (response.data!["data"] as List<dynamic>).map<Task>((e) => Task.fromJson(e)).toList();
  }
}
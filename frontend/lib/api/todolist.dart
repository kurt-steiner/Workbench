import 'package:dio/dio.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';
import 'package:path/path.dart' show join;

class TodoListApi {
  final String baseUrl;
  late Dio instance;
  final String uid;
  String get url => join(baseUrl, "todolist");

  Map<String, String> get headers => {
    "uid": uid
  };

  TodoListApi({required this.baseUrl, required this.uid}) {
    instance = Dio(BaseOptions(
        baseUrl: url,
        headers: headers
    ));
  }

  String get priorityUrl => join(url, "priority");
  String get tagUrl => join(url, "tag");
  String get taskUrl => join(url, "task");
  String get taskGroupUrl => join(url, "taskgroup");
  String get taskProjectUrl => join(url, "taskproject");
  String get subTaskUrl => join(url, "subtask");

  // CRUD priority
  Future<Priority> insertPriority(PostPriorityRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.post(priorityUrl, data: request.toJson());
    return Priority.fromJson(response.data!["data"]);
  }

  Future<void> deletePriority(int id) async {
    await instance.delete(join(priorityUrl, id.toString()));
  }

  Future<Priority> updatePriority(UpdatePriorityRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.put(priorityUrl, data: request.toJson());
    return Priority.fromJson(response.data!["data"]);
  }

  Future<List<Priority>> findPriorities(int parentid) async {
    final Response<Map<String, dynamic>> response = await instance.get(priorityUrl, queryParameters: {
      "parentid": parentid
    });

    return (response.data!["data"] as List<dynamic>).map<Priority>((e) => Priority.fromJson(e)).toList();
  }
  // CRUD tag
  Future<Tag> insertTag(PostTagRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.post(tagUrl, data: request.toJson());
    return Tag.fromJson(response.data!["data"]);
  }

  Future<void> deleteTag(int id) async {
    await instance.delete(join(tagUrl, id.toString()));
  }

  Future<Tag> updateTag(UpdateTagRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.put(tagUrl, data: request.toJson());
    return Tag.fromJson(response.data!["data"]);
  }

  Future<List<Tag>> findTags(int parentid) async {
    final Response<Map<String, dynamic>> response = await instance.get(tagUrl, queryParameters: {
      "parentid": parentid
    });

    return (response.data!["data"] as List<dynamic>).map<Tag>((e) => Tag.fromJson(e)).toList();
  }
  // CRUD task
  Future<Task> insertTask(PostTaskRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.post(taskUrl, data: request.toJson());
    return Task.fromJson(response.data!["data"]);
  }

  Future<void> deleteTask(int id) async {
    await instance.delete(join(taskUrl, id.toString()));
  }

  Future<Task> updateTask(UpdateTaskRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.put(taskUrl, data: request.toJson());
    return Task.fromJson(response.data!["data"]);
  }

  Future<void> insertTaskTag(PostTaskTagRequest request) async {
    await instance.post(join(taskUrl, "tag"), data: request.toJson());
  }

  Future<void> removeDeadline(int id) async {
    await instance.delete(join(taskUrl, "deadline/$id"));
  }

  Future<void> removeNotifyTime(int id) async {
    await instance.delete(join(taskUrl, "notify-time/$id"));
  }

  Future<void> removeTag(int taskid, int tagid) async {
    await instance.delete(join(taskUrl, "tag"), queryParameters: {
      "taskid": taskid,
      "tagid": tagid
    });
  }

  Future<void> removeNote(int id) async {
    await instance.delete(join(taskUrl, "note", id.toString()));
  }

  Future<Task> findTask(int id) async {
    final Response<Map<String, dynamic>> response = await instance.get(join(taskUrl, id.toString()));
    return Task.fromJson(response.data!["data"]);
  }

  // CRUD taskgroup
  Future<TaskGroup> insertTaskGroup(PostTaskGroupRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.post(taskGroupUrl, data: request.toJson());
    return TaskGroup.fromJson(response.data!["data"]);
  }

  Future<void> deleteTaskGroup(int id) async {
    await instance.delete(join(taskGroupUrl, id.toString()));
  }

  Future<TaskGroup> updateTaskGroup(UpdateTaskGroupRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.put(taskGroupUrl, data: request.toJson());
    return TaskGroup.fromJson(response.data!["data"]);
  }

  Future<void> reorderTaskGroup(ReorderRequest request) async {
    await instance.put(join(taskGroupUrl, "reorder"), data: request.toJson());
  }

  Future<void> reorderTask(ReorderRequest request) async {
    await instance.put(join(taskUrl, "reorder"), data: request.toJson());
  }

  Future<List<TaskGroup>> findTaskGroups(int parentid) async {
    final Response<Map<String, dynamic>> response = await instance.get(taskGroupUrl, queryParameters: {
      "parentid": parentid
    });

    return (response.data!["data"] as List<dynamic>).map<TaskGroup>((e) => TaskGroup.fromJson(e)).toList();
  }

  Future<TaskGroup> findTaskGroup(int id) async {
    final Response<Map<String, dynamic>> response = await instance.get(join(taskGroupUrl, id.toString()));
    return TaskGroup.fromJson(response.data!["data"]);
  }
  // CRUD taskproject
  Future<TaskProject> insertTaskProject(PostTaskProjectRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.post(taskProjectUrl, data: request.toJson());
    return TaskProject.fromJson(response.data!["data"]);
  }

  Future<void> deleteTaskProject(int id) async {
    await instance.delete(join(taskProjectUrl, id.toString()));
  }

  Future<TaskProject> updateTaskProject(UpdateTaskProjectRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.put(taskProjectUrl, data: request.toJson());
    return TaskProject.fromJson(response.data!["data"]);
  }

  Future<List<TaskProject>> findTaskProjects() async {
    final Response<Map<String, dynamic>> response = await instance.get(taskProjectUrl);
    return (response.data!["data"] as List<dynamic>).map<TaskProject>((e) => TaskProject.fromJson(e)).toList();
  }

  Future<TaskProject> findTaskProject(int id) async {
    final Response<Map<String, dynamic>> response = await instance.get(join(taskProjectUrl, id.toString()));
    return TaskProject.fromJson(response.data!["data"]);
  }

  // CRUD SubTask
  Future<SubTask> insertSubTask(PostSubTaskRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.post(subTaskUrl, data: request.toJson());
    return SubTask.fromJson(response.data!["data"]);
  }

  Future<void> deleteSubTask(int id) async {
    await instance.delete(join(subTaskUrl, id.toString()));
  }

  Future<SubTask> updateSubTask(UpdateSubTaskRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.put(subTaskUrl, data: request.toJson());
    return SubTask.fromJson(response.data!["data"]);
  }
}
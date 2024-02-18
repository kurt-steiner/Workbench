import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/state/todolist.dart';
import 'package:provider/provider.dart';

class TaskProjectManage extends StatefulWidget {
  @override
  _TaskProjectManageState createState() => _TaskProjectManageState();
}

class _TaskProjectManageState extends State<TaskProjectManage> with StateMixin {

  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();

    throw UnimplementedError();
  }
}
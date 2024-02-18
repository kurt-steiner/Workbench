import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:frontend/widget/todolist/taskproject.dart';
import 'package:provider/provider.dart';

class TaskProjectBoard extends StatelessWidget with StateMixin {
  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();
    
    return Scaffold(
      appBar: AppBar(title: const Text("任务项目"),),
      body: buildFuture(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          todoListNavigationKey.currentState!.pushNamed("todolist/taskproject", arguments: "add");
        },

        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget buildFuture(BuildContext context) {
    return FutureBuilder(
        future: todoListState.loadTaskProjects(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return Center(
              child: Text("${snapshot.error}"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Selector<TodoListState, String>(
            selector: (_, state) => todoListState.taskProjects.map((e) => "${e.id}-${e.name}-${e.avatarid}").join(","),
            builder: (_, value, child) {
              return Wrap(
                children: todoListState.taskProjects.map<Widget>(
                        (e) => TaskProjectWidget(taskProject: e)
                ).toList()
              );
            },
          );

        }
    );
  }
}
import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:provider/provider.dart';

class TaskProjectWidget extends StatelessWidget with StateMixin {
  final TaskProject taskProject;

  TaskProjectWidget({required this.taskProject});

  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();

    return InkWell(
      onTap: () {
        todoListState.setCurrentTaskProject(taskProject);
        todoListNavigationKey.currentState!.pushNamed("todolist/taskgroups");
      },

      child: buildCard(context),
    );
  }

  Widget buildCard(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: todoListSettings["widget.taskproject.width"],
        height: todoListSettings["widget.taskproject.height"],
        decoration: BoxDecoration(
          image: DecorationImage(
            image: buildCover(context),
            fit: BoxFit.cover,
            alignment: Alignment.topLeft,
          ),
          
          borderRadius: todoListSettings["widget.taskproject.cover.border-radius"]
        ),

        child: Align(
          alignment: const FractionalOffset(0.05, 0.05),
          child: Text(taskProject.name, style: todoListSettings["widget.taskproject.cover.title.style"])
        ),
      ),
    );
  }

  ImageProvider<Object> buildCover(BuildContext context) {
    late ImageProvider<Object> cover;
    if (taskProject.avatarid == null) {
      // cover = FileImage(File("assets/cover.jpg"));
      cover = const AssetImage("assets/cover.jpg");
    } else {
      cover = NetworkImage(todoListState.imageUrl(taskProject.avatarid!));
    }

    return cover;
  }
}
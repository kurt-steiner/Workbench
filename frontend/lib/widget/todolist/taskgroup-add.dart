import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:provider/provider.dart';

class TaskGroupAdd extends StatefulWidget {
  @override
  State<TaskGroupAdd> createState() => _TaskGroupAddState();
}

class _TaskGroupAddState extends State<TaskGroupAdd> with StateMixin{
  final controller = TextEditingController();
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();
    
    return SizedBox(
      width: todoListSettings["widget.taskgroup.width"],
      child: expanded ? buildExpand(context) : buildEntry(context)
    );
  }
  
  Widget buildEntry(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          expanded = true;
        });
      },

      child: Card(
        color: Colors.blue.withOpacity(0.01),
        child: const ListTile(
          leading: Icon(Icons.add, color: Colors.white,),
          title: Text("添加一个列表", style: TextStyle(color: Colors.white),),
        )
      ),
    );
  }
  
  Widget buildExpand(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "输入列表标题",
                border: InputBorder.none,
                hintStyle: TextStyle(fontWeight: FontWeight.bold)
              ),
            ),
          ),

          ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      final request = PostTaskGroupRequest(parentid: todoListState.currentTaskProject!.id, name: controller.text.trim());
                      await todoListState.insertTaskGroup(request);
            
                      setState(() {
                        expanded = false;
                      });
            
                      controller.clear();
                    },
            
                    child: const Text("添加列表")
                ),
            
                IconButton(
                  onPressed: () {
                    setState(() {
                      expanded = false;
                    });
            
                    controller.clear();
                  },
            
                  icon: const Icon(Icons.close)
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
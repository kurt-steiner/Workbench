import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/image.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/todolist.dart';
import 'package:provider/provider.dart';

class TaskProjectAddEdit extends StatefulWidget {
  @override
  _TaskProjectAddEditState createState() => _TaskProjectAddEditState();
}

class _TaskProjectAddEditState extends State<TaskProjectAddEdit> with StateMixin {
  final PostTaskProjectRequest postRequest = PostTaskProjectRequest(name: "", avatarid: null, profile: null);
  final UpdateTaskProjectRequest updateRequest = UpdateTaskProjectRequest(id: -1, name: null, avatarid: null, profile: null);
  final TextEditingController nameController = TextEditingController();
  final TextEditingController profileController = TextEditingController();

  int? imageId;
  final notifier = ValueNotifier(false);
  
  bool get enable => isAdd ? postRequest.name.isNotEmpty : (updateRequest.name?.isNotEmpty ?? false);

  // this should be called after build
  String get argument => (ModalRoute.of(context)!.settings.arguments as String);
  bool get isEdit => argument == "edit";
  bool get isAdd => argument == "add";

  set name(String value) {
    if (isEdit) {
      updateRequest.name = value;
    } else {
      postRequest.name = value;
    }

    notifier.value = enable;
  }

  set avatarid(int id) {
    if (isEdit) {
      updateRequest.avatarid = id;
    } else {
      postRequest.avatarid = id;
    }
  }

  set profile(String value) {
    if (isEdit) {
      updateRequest.profile = value;
    } else {
      postRequest.profile = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    todoListState = context.read<TodoListState>();
    if (isEdit) {
      updateRequest.id = todoListState.currentTaskProject!.id;
      updateRequest.name = todoListState.currentTaskProject!.name;
      updateRequest.avatarid = todoListState.currentTaskProject!.avatarid;
      updateRequest.profile = todoListState.currentTaskProject!.profile;

      imageId = updateRequest.avatarid;

      nameController.text = updateRequest.name ?? "";
      profileController.text = updateRequest.profile ?? "";
      notifier.value = enable;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("添加任务项目"),
        actions: [
          ValueListenableBuilder(
            valueListenable: notifier,
            builder: (_, value, child) => IconButton(
              onPressed: value ? () async {
                if (isAdd) {
                  await todoListState.insertTaskProject(postRequest);
                } else {
                  await todoListState.updateTaskProject(updateRequest);
                }

                todoListNavigationKey.currentState!.pop();
              } : null,
              
              icon: const Icon(Icons.check),
            ),
          ),
          
          IconButton(
            onPressed: () async {
              todoListNavigationKey.currentState!.pop();
            },
            
            icon: const Icon(Icons.close),
          )
        ],
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return ListView(
      children: [
        buildInputName(context),
        buildUploadImage(context),
        buildProfile(context)
      ],
    );
  }

  Widget buildInputName(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.title),
      title: TextField(
        controller: nameController,
        onChanged: (String? value) {
          if (value != null) {
            name = value.trim();
          }
        },
      ),
    );
  }

  Widget buildUploadImage(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => ListTile(
        onTap: () async {
          final result = await FilePicker.platform.pickFiles(type: FileType.image);
          if (result != null) {
            final multipartFile = await MultipartFile.fromFile(result.files.single.path!);

            final image = await todoListState.insertImage(multipartFile);
            avatarid = image.id;

            setState(() {
              imageId = image.id;
            });
          }
        },

        leading: const Icon(Icons.image_outlined),
        title: imageId == null ? null : Image.network(todoListState.imageUrl(imageId!), height: todoListSettings["page.taskproject-add-edit.image.height"],),
      ),
    );
  }
  
  Widget buildProfile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.text_snippet_outlined),
      title: TextField(
        controller: profileController,
        minLines: 3,
        maxLines: 5,
        decoration: const InputDecoration(
          border: OutlineInputBorder()
        ),
        onChanged: (String? value) async {
          if (value != null) {
            profile = value.trim();
          }
        },
      ),
    );
  }

}
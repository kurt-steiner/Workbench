import 'package:flutter/material.dart';
import 'package:frontend/api/login.dart';
import 'package:frontend/global.dart';
import 'package:frontend/global.dart' as global;
import 'package:frontend/state/clipboard.dart';
import 'package:frontend/state/daily-attendance.dart';
import 'package:frontend/state/todolist.dart';

class LoginPage extends StatelessWidget {
  final baseUrlController = TextEditingController(text: global.baseUrl ?? "http://localhost:8080");
  final uidController = TextEditingController(text: global.uid ?? "Unnamed");
  late LoginApi api;

  String get baseUrl => baseUrlController.text;
  String get uid => uidController.text;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text("Login"),),
      body: buildBody(context),
    );
  }

  
  // 这里指定 baseurl 和 uid
  Widget buildBody(BuildContext context) {
    Widget child = Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: TextField(
              controller: baseUrlController,
              decoration: const InputDecoration(
                hintText: "输入服务器地址"
              ),
            ),
          ),
          
          ListTile(
            title: TextField(
              controller: uidController,
              decoration: const InputDecoration(
                hintText: "输入uid"
              ),
            ),
          ),
          
          ListTile(
            title: OutlinedButton(
                onPressed: () async {
                  if (uid.isEmpty || baseUrl.isEmpty) {
                    return;
                  }

                  api = LoginApi(uid: uid, baseUrl: baseUrl);
                  bool result = await api.loginCheck();

                  if (result) {
                    global.baseUrl = baseUrl;
                    global.uid = uid;
                    clipboardState = ClipboardState();
                    todoListState = TodoListState();
                    dailyAttendanceState = DailyAttendanceState(plugin: plugin);
                    loginIn.value = true;
                  }
                },

                child: const Text("登录")
            ),
          )
        ],
      ),
    );

    return Center(
      child: FractionallySizedBox(
          widthFactor: 0.65,
          child: child
      ),
    );
  }
}
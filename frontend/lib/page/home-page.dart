import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/request/clipboard.dart';
import 'package:frontend/state/clipboard.dart';
import 'package:frontend/widget/clipboard/clipboard.dart';
import 'package:frontend/global.dart' as global;
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget with StateMixin {
  @override
  Widget build(BuildContext context) {
    clipboardState = context.read<ClipboardState>();
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("主页 ${global.uid!}"),
        actions: [
          TextButton(
              onPressed: () async {
                ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data == null) {
                  return;
                }

                if (data.text == null) {
                  return;
                }

                PostTextRequest request = PostTextRequest(text: data.text!);
                await clipboardState.insertOne(request);
                print("inserted");
              },
              child: const Text("从剪切板导入")
          ),

          IconButton(
            onPressed: () {
              global.loginIn.value = false;
            },

            icon: const Icon(Icons.logout, color: Colors.red,),
          )
        ],
      ),


      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: ClipboardWidget(),
      )
    );
  }
}
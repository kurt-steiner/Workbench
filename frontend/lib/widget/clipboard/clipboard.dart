import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/request/clipboard.dart';
import 'package:frontend/state/clipboard.dart';
import 'package:provider/provider.dart';

class ClipboardWidget extends StatelessWidget with StateMixin {
  TextEditingController controller = TextEditingController();
  ScaffoldMessengerState? _messenger;
  ScaffoldMessengerState get messenger => _messenger!;
  set messenger(ScaffoldMessengerState value) => _messenger ??= value;

  @override
  Widget build(BuildContext context) {
    clipboardState = context.read<ClipboardState>();
    messenger = ScaffoldMessenger.of(context);

    return FutureBuilder(
        future: clipboardState.findAll(0),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(child: buildTable(context));
        }
    );

  }

  Widget buildTable(BuildContext context) {
    return PaginatedDataTable(
      columns: const [
        DataColumn(label: Text("文字")),
        DataColumn(label: Text("操作")),
      ],

      source: clipboardState,
      onPageChanged: (page) async {
        await clipboardState.findAll(page);
      },

    );
  }


  Widget buildAdd(BuildContext context) {
    return ListTile(
      title: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: "输入文字"
        ),
      ),

      trailing: IconButton(
        onPressed: () async {
          if (controller.text.isEmpty) {
            return;
          }

          PostTextRequest request = PostTextRequest(text: controller.text);
          controller.clear();
          await clipboardState.insertOne(request);
        },

        icon: const Icon(Icons.add, color: Colors.blue,),
      ),
    );
  }
}
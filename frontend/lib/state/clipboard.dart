import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/api/clipboard.dart';
import 'package:frontend/model/clipboard.dart';
import 'package:frontend/request/clipboard.dart';
import 'package:frontend/global.dart' as global;
class ClipboardState extends DataTableSource implements ChangeNotifier {
  late final ClipboardApi api;

  int size;
  int totalPages = 0;

  final List<ClipboardText> data = [];

  ClipboardState({this.size = 20}) {
    api = ClipboardApi(uid: global.uid!, baseUrl: global.baseUrl!);
  }

  @override
  int get rowCount => data.length;

  Future<bool> findAll(int page) async {
    PageClipboardText result = await api.findAll(page: page, size: this.size);
    data
      ..clear()
      ..addAll(result.content);

    totalPages = result.totalPages;
    notifyListeners();
    return true;
  }

  Future<void> insertOne(PostTextRequest request) async {
    ClipboardText text = await api.insertOne(request);
    data.insert(0, text);
    notifyListeners();
  }

  Future<void> deleteOne(int id) async {
    await api.deleteOne(id);
    data.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    // TODO: implement getRow
    if (index >= data.length) {
      print("here index is $index, date.length is ${data.length}");
      return null;
    }

    return DataRow(
      cells: [
        DataCell(buildItem(data[index])),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildCopyButton(data[index]),
            buildDeleteButton(data[index])
          ],
        ))
      ]
    );
  }

  Widget buildItem(ClipboardText text) {
    return Text(text.text, overflow: TextOverflow.ellipsis,);
  }

  Widget buildCopyButton(ClipboardText text) {
    return TextButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: text.text));
      },

      child: const Text("复制"),
    );
  }

  Widget buildDeleteButton(ClipboardText text) {
    return TextButton(
      onPressed: () async {
        await deleteOne(text.id);
      },

      child: const Text("删除"),
    );
  }


  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

}
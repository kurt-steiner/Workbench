import 'package:flutter/material.dart';

class ClipboardText {
  final int id;
  final String text;
  final DateTime createTime;

  ClipboardText({required this.id, required this.text, required this.createTime});

  factory ClipboardText.fromJson(Map<String, dynamic> json) {
    return ClipboardText(id: json["id"], text: json["text"], createTime: DateTime.parse(json["createTime"]));
  }
}

class PageClipboardText {
  List<ClipboardText> content;
  int totalPages;

  PageClipboardText({required this.content, required this.totalPages});

  factory PageClipboardText.fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonContent = json["content"];
    int jsonTotalPages = json["totalPages"];

    return PageClipboardText(
        content: jsonContent.map<ClipboardText>((e) => ClipboardText.fromJson(e)).toList(),
        totalPages: jsonTotalPages
    );
  }
}
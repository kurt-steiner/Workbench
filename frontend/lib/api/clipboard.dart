import 'package:dio/dio.dart';
import 'package:frontend/model/clipboard.dart';
import 'package:frontend/request/clipboard.dart';
import 'package:path/path.dart';

class ClipboardApi {
  late Dio instance;
  final String uid;
  final String baseUrl;
  String get url => join(baseUrl, "clipboard");

  Map<String, String> get headers => {
    "uid": uid
  };

  ClipboardApi({required this.uid, required this.baseUrl}) {
    instance = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: headers
    ));
  }

  Future<PageClipboardText> findAll({int page = 0, required int size}) async {
    Response<Map<String, dynamic>> response = await instance.get(url, queryParameters: {
      "page": page,
      "size": size
    });

    return PageClipboardText.fromJson(response.data!["data"]);
  }

  Future<ClipboardText> insertOne(PostTextRequest request) async {
    Response<Map<String, dynamic>> response = await instance.post(url, data: request.toJson());
    return ClipboardText.fromJson(response.data!["data"]);
  }

  Future<void> deleteOne(int id) async {
    await instance.delete(join(url, "$id"));
  }
}
import 'package:dio/dio.dart';
import 'package:frontend/model/image.dart';
import 'package:path/path.dart' show join;

class ImageApi {
  final String baseUrl;
  String get url => join(baseUrl, "image");
  String uid;
  late Dio instance;


  Map<String, String> get headers => {
    "uid": uid
  };

  ImageApi({required this.baseUrl, required this.uid}) {
    instance = Dio(BaseOptions(
        baseUrl: url,
        headers: headers
    ));
  }

  Future<ImageItem> insertOne(MultipartFile file) async {
    final data = FormData.fromMap({
      "file": file
    });

    final Response<Map<String, dynamic>> response = await instance.post("/upload", data: data);
    return ImageItem.fromJson(response.data!["data"]);
  }
}
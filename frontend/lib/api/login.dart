import 'package:dio/dio.dart';
import 'package:path/path.dart';

class LoginApi {
  late Dio instance;
  final String uid;
  final String baseUrl;
  String get url => join(baseUrl, "login-check");

  Map<String, String> get headers => {
    "uid": uid
  };

  LoginApi({required this.uid, required this.baseUrl}) {
    instance = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: headers
    ));
  }

  Future<bool> loginCheck() async {
    try {
      instance.get(url, queryParameters: {
        "uid": uid
      });

      return true;
    } on DioException {
      return false;
    }
  }
}
import 'package:dio/dio.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';

class NewClient {
  Dio init() {
    Dio dio = Dio();
    dio.options.baseUrl = APIEndPoints.base;

    final token = getJwtToken();
    dio.options.headers['authorization'] = "Bearer $token";

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (e, handler) {
          return handler.next(e);
        },
      ),
    );
    return dio;
  }
}

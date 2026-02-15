import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/environment.dart';

class DioClient {
  final Dio _dio;

  DioClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: Environment.baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(
            seconds: 30,
          ), // Increased timeout just in case
          contentType: Headers.jsonContentType,
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // You could add global error handling here
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}

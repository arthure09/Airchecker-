import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthorizationInterceptor extends Interceptor {
  final String? apiToken = dotenv.env['WAQI_API_KEY'];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters['token'] = apiToken;

    return super.onRequest(options, handler);
  }
}

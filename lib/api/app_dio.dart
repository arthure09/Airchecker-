import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'app_dio.g.dart';

@riverpod
Dio appDio(AppDioRef ref) {
  // 1) Grab your WAQI key from .env
  final token = dotenv.env['WAQI_API_KEY']?.trim() ?? '';
  if (token.isEmpty) {
    throw StateError('Missing WAQI_API_KEY in .env');
  }

  // 2) Create Dio with baseUrl + default token query
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.waqi.info',
    queryParameters: {'token': token},
  ));

  // 3) Log every outgoing request URL
  if (kDebugMode) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print(
              '🌐 Requesting → '
                  '${options.baseUrl}${options.path}'
                  '?token=${options.queryParameters['token']}'
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          // 4) Log status & body of each response
          print('🌐 Response status: ${response.statusCode}');
          print('🌐 Response data: ${response.data}');
          handler.next(response);
        },
        onError: (DioError e, handler) {
          print('❌ Request error: ${e.error}');
          handler.next(e);
        },
      ),
    );
  }

  return dio;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'api/app_dio.dart';
import 'model/api/aqi_info/aqi_info.dart';

final aqiNotifierProvider = FutureProvider<AqiInfo>((ref) async {
  final dio = ref.watch(appDioProvider);

  print('🔄 [aqi_notifier] Fetching /feed/here …');
  final response = await dio.get('/feed/here');

  // 1) Dump the raw response data
  print('🔄 [aqi_notifier] raw response.data → ${response.data.runtimeType}: ${response.data}');

  // 2) Ensure we got a Map
  final json = response.data;
  if (json == null) {
    throw Exception('[aqi_notifier] response.data == null');
  }
  if (json is! Map<String, dynamic>) {
    throw Exception('[aqi_notifier] response.data is not a Map<String,dynamic>: $json');
  }

  // 3) Inspect status field
  final status = json['status'];
  print('🔄 [aqi_notifier] status → $status');
  if (status != 'ok') {
    final errMsg = json['data'] ?? '(no data)';
    throw Exception('[aqi_notifier] WAQI error: $errMsg');
  }

  // 4) Inspect the “data” field before casting
  final rawData = json['data'];
  print('🔄 [aqi_notifier] rawData → ${rawData.runtimeType}: $rawData');
  if (rawData == null) {
    throw Exception('[aqi_notifier] json["data"] is null');
  }
  if (rawData is! Map<String, dynamic>) {
    throw Exception('[aqi_notifier] json["data"] is not a Map<String,dynamic>: $rawData');
  }

  // 5) Finally safe to parse
  return AqiInfo.fromJson(rawData);
});

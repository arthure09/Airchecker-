import 'package:freezed_annotation/freezed_annotation.dart';
import 'aqi_iaqi.dart';   // ← add this import

part 'aqi_detail.freezed.dart';
part 'aqi_detail.g.dart';

@freezed
class AqiDetail with _$AqiDetail {
  const factory AqiDetail({
    AqiIaqi? pm25,
    AqiIaqi? pm10,
    AqiIaqi? o3,
    AqiIaqi? no2,
    AqiIaqi? so2,
    AqiIaqi? co,
    AqiIaqi? h,
    AqiIaqi? t,
    AqiIaqi? w,
    AqiIaqi? p,
    AqiIaqi? dew,
    AqiIaqi? r,
  }) = _AqiDetail;

  factory AqiDetail.fromJson(Map<String, dynamic> json) =>
      _$AqiDetailFromJson(json);
}

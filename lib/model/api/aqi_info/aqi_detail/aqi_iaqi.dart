import 'package:freezed_annotation/freezed_annotation.dart';

part 'aqi_iaqi.freezed.dart';
part 'aqi_iaqi.g.dart';

@freezed
class AqiIaqi with _$AqiIaqi {
  const factory AqiIaqi({
    @JsonKey(name: 'v') required double v,
  }) = _AqiIaqi;

  factory AqiIaqi.fromJson(Map<String, dynamic> json) =>
      _$AqiIaqiFromJson(json);
}

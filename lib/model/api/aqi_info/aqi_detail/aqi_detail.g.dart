// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aqi_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AqiDetailImpl _$$AqiDetailImplFromJson(Map<String, dynamic> json) =>
    _$AqiDetailImpl(
      pm25: json['pm25'] == null
          ? null
          : AqiIaqi.fromJson(json['pm25'] as Map<String, dynamic>),
      pm10: json['pm10'] == null
          ? null
          : AqiIaqi.fromJson(json['pm10'] as Map<String, dynamic>),
      o3: json['o3'] == null
          ? null
          : AqiIaqi.fromJson(json['o3'] as Map<String, dynamic>),
      no2: json['no2'] == null
          ? null
          : AqiIaqi.fromJson(json['no2'] as Map<String, dynamic>),
      so2: json['so2'] == null
          ? null
          : AqiIaqi.fromJson(json['so2'] as Map<String, dynamic>),
      co: json['co'] == null
          ? null
          : AqiIaqi.fromJson(json['co'] as Map<String, dynamic>),
      h: json['h'] == null
          ? null
          : AqiIaqi.fromJson(json['h'] as Map<String, dynamic>),
      t: json['t'] == null
          ? null
          : AqiIaqi.fromJson(json['t'] as Map<String, dynamic>),
      w: json['w'] == null
          ? null
          : AqiIaqi.fromJson(json['w'] as Map<String, dynamic>),
      p: json['p'] == null
          ? null
          : AqiIaqi.fromJson(json['p'] as Map<String, dynamic>),
      dew: json['dew'] == null
          ? null
          : AqiIaqi.fromJson(json['dew'] as Map<String, dynamic>),
      r: json['r'] == null
          ? null
          : AqiIaqi.fromJson(json['r'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AqiDetailImplToJson(_$AqiDetailImpl instance) =>
    <String, dynamic>{
      'pm25': instance.pm25,
      'pm10': instance.pm10,
      'o3': instance.o3,
      'no2': instance.no2,
      'so2': instance.so2,
      'co': instance.co,
      'h': instance.h,
      't': instance.t,
      'w': instance.w,
      'p': instance.p,
      'dew': instance.dew,
      'r': instance.r,
    };

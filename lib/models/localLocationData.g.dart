// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localLocationData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalLocationData _$LocalLocationDataFromJson(Map<String, dynamic> json) =>
    LocalLocationData(
      DateTime.parse(json['locationDateTime'] as String),
      (json['locationLatitude'] as num).toDouble(),
      (json['locationLongitude'] as num).toDouble(),
      json['isAppActive'] as bool,
    );

Map<String, dynamic> _$LocalLocationDataToJson(LocalLocationData instance) =>
    <String, dynamic>{
      'locationDateTime': instance.locationDateTime.toIso8601String(),
      'locationLatitude': instance.locationLatitude,
      'locationLongitude': instance.locationLongitude,
      'isAppActive': instance.isAppActive,
    };

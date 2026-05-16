// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MonitoredApp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitoredApp _$MonitoredAppFromJson(Map<String, dynamic> json) => MonitoredApp(
  id: json['id'] as String,
  name: json['name'] as String,
  platformId: json['platformId'] as String,
  iconHint: json['iconHint'] as String?,
);

Map<String, dynamic> _$MonitoredAppToJson(MonitoredApp instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'platformId': instance.platformId,
      'iconHint': instance.iconHint,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppResourceSnapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppResourceSnapshot _$AppResourceSnapshotFromJson(Map<String, dynamic> json) =>
    AppResourceSnapshot(
      app: MonitoredApp.fromJson(json['app'] as Map<String, dynamic>),
      isRunning: json['isRunning'] as bool,
      runState:
          $enumDecodeNullable(_$AppRunStateEnumMap, json['runState']) ??
          ((json['isRunning'] as bool)
              ? AppRunState.background
              : AppRunState.stopped),
      cpu: ResourceMetric.fromJson(json['cpu'] as Map<String, dynamic>),
      memory: ResourceMetric.fromJson(json['memory'] as Map<String, dynamic>),
      disk: ResourceMetric.fromJson(json['disk'] as Map<String, dynamic>),
      network: ResourceMetric.fromJson(json['network'] as Map<String, dynamic>),
      sampledAt: DateTime.parse(json['sampledAt'] as String),
      source: json['source'] as String,
    );

Map<String, dynamic> _$AppResourceSnapshotToJson(
  AppResourceSnapshot instance,
) => <String, dynamic>{
  'app': instance.app.toJson(),
  'isRunning': instance.isRunning,
  'runState': _$AppRunStateEnumMap[instance.runState]!,
  'cpu': instance.cpu.toJson(),
  'memory': instance.memory.toJson(),
  'disk': instance.disk.toJson(),
  'network': instance.network.toJson(),
  'sampledAt': instance.sampledAt.toIso8601String(),
  'source': instance.source,
};

const _$AppRunStateEnumMap = {
  AppRunState.foreground: 'foreground',
  AppRunState.background: 'background',
  AppRunState.stopped: 'stopped',
  AppRunState.confirmed: 'confirmed',
  AppRunState.recentlyUsed: 'recentlyUsed',
  AppRunState.unknown: 'unknown',
};

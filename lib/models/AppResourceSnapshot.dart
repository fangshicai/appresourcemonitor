import 'package:appresourcemonitor/models/MonitoredApp.dart';
import 'package:appresourcemonitor/models/ResourceMetric.dart';
import 'package:json_annotation/json_annotation.dart';

part 'AppResourceSnapshot.g.dart';

enum AppRunState {
  @JsonValue('foreground')
  foreground,
  @JsonValue('background')
  background,
  @JsonValue('stopped')
  stopped,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('recentlyUsed')
  recentlyUsed,
  @JsonValue('unknown')
  unknown,
}

@JsonSerializable(explicitToJson: true)
class AppResourceSnapshot {
  const AppResourceSnapshot({
    required this.app,
    required this.isRunning,
    required this.runState,
    required this.cpu,
    required this.memory,
    required this.disk,
    required this.network,
    required this.sampledAt,
    required this.source,
  });

  final MonitoredApp app;
  final bool isRunning;
  final AppRunState runState;
  final ResourceMetric cpu;
  final ResourceMetric memory;
  final ResourceMetric disk;
  final ResourceMetric network;
  final DateTime sampledAt;
  final String source;

  bool get isBackgroundRunning => runState == AppRunState.background;

  String get statusLabel {
    return switch (runState) {
      AppRunState.foreground => '前台运行',
      AppRunState.background => '后台运行',
      AppRunState.stopped => '未运行',
      AppRunState.confirmed => '当前可确认',
      AppRunState.recentlyUsed => '最近使用',
      AppRunState.unknown => '未确认',
    };
  }

  factory AppResourceSnapshot.fromJson(Map<String, dynamic> json) =>
      _$AppResourceSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$AppResourceSnapshotToJson(this);
}

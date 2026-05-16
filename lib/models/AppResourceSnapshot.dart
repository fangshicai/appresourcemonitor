import 'package:appresourcemonitor/models/MonitoredApp.dart';
import 'package:appresourcemonitor/models/ResourceMetric.dart';
import 'package:json_annotation/json_annotation.dart';

part 'AppResourceSnapshot.g.dart';

@JsonSerializable(explicitToJson: true)
class AppResourceSnapshot {
  const AppResourceSnapshot({
    required this.app,
    required this.isRunning,
    required this.cpu,
    required this.memory,
    required this.disk,
    required this.sampledAt,
    required this.source,
  });

  final MonitoredApp app;
  final bool isRunning;
  final ResourceMetric cpu;
  final ResourceMetric memory;
  final ResourceMetric disk;
  final DateTime sampledAt;
  final String source;

  String get statusLabel => isRunning ? '运行中' : '未运行';

  factory AppResourceSnapshot.fromJson(Map<String, dynamic> json) =>
      _$AppResourceSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$AppResourceSnapshotToJson(this);
}

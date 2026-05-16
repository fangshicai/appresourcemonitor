import 'package:appresourcemonitor/models/monitored_app.dart';
import 'package:appresourcemonitor/models/resource_metric.dart';

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

  factory AppResourceSnapshot.fromMap(Map<String, Object?> map) {
    return AppResourceSnapshot(
      app: MonitoredApp.fromMap(map['app'] as Map<String, Object?>),
      isRunning: map['isRunning'] as bool,
      cpu: ResourceMetric.fromMap(map['cpu'] as Map<String, Object?>),
      memory: ResourceMetric.fromMap(map['memory'] as Map<String, Object?>),
      disk: ResourceMetric.fromMap(map['disk'] as Map<String, Object?>),
      sampledAt: DateTime.parse(map['sampledAt'] as String),
      source: map['source'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'app': app.toMap(),
      'isRunning': isRunning,
      'cpu': cpu.toMap(),
      'memory': memory.toMap(),
      'disk': disk.toMap(),
      'sampledAt': sampledAt.toIso8601String(),
      'source': source,
    };
  }
}

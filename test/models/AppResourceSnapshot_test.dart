import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';
import 'package:appresourcemonitor/models/MonitoredApp.dart';
import 'package:appresourcemonitor/models/ResourceMetric.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppResourceSnapshot', () {
    test('formats resource metrics for display', () {
      final snapshot = AppResourceSnapshot(
        app: const MonitoredApp(
          id: 'com.example.maps',
          name: 'Maps',
          platformId: 'com.example.maps',
        ),
        isRunning: true,
        runState: AppRunState.background,
        cpu: const ResourceMetric(
          label: 'CPU',
          value: 12.5,
          unit: '%',
          percent: 12.5,
        ),
        memory: const ResourceMetric(
          label: '内存',
          value: 512,
          unit: 'MB',
          percent: 25,
        ),
        disk: const ResourceMetric(
          label: '磁盘',
          value: 1.2,
          unit: 'GB',
          percent: 10,
        ),
        network: const ResourceMetric(
          label: '网络',
          value: 128,
          unit: 'KB/s',
          percent: 12.8,
        ),
        sampledAt: DateTime(2026, 5, 16, 9, 30),
        source: 'fake',
      );

      expect(snapshot.statusLabel, '后台运行');
      expect(snapshot.cpu.displayValue, '12.5%');
      expect(snapshot.memory.displayValue, '512.0 MB');
      expect(snapshot.disk.displayValue, '1.2 GB');
      expect(snapshot.network.displayValue, '128.0 KB/s');
    });

    test('round-trips nested JSON data', () {
      final snapshot = AppResourceSnapshot(
        app: const MonitoredApp(
          id: 'com.example.maps',
          name: 'Maps',
          platformId: 'com.example.maps',
        ),
        isRunning: true,
        runState: AppRunState.background,
        cpu: const ResourceMetric(
          label: 'CPU',
          value: 12.5,
          unit: '%',
          percent: 12.5,
        ),
        memory: const ResourceMetric(
          label: '内存',
          value: 512,
          unit: 'MB',
          percent: 25,
        ),
        disk: const ResourceMetric(
          label: '磁盘',
          value: 1.2,
          unit: 'GB',
          percent: 10,
        ),
        network: const ResourceMetric(
          label: '网络',
          value: 128,
          unit: 'KB/s',
          percent: 12.8,
        ),
        sampledAt: DateTime(2026, 5, 16, 9, 30),
        source: 'fake',
      );

      final parsed = AppResourceSnapshot.fromJson(snapshot.toJson());

      expect(parsed.app.platformId, 'com.example.maps');
      expect(parsed.runState, AppRunState.background);
      expect(parsed.cpu.displayValue, '12.5%');
      expect(parsed.network.displayValue, '128.0 KB/s');
      expect(parsed.sampledAt, DateTime(2026, 5, 16, 9, 30));
    });

    test('defaults old snapshots to stopped or background run state', () {
      final runningSnapshot = AppResourceSnapshot.fromJson({
        'app': {
          'id': 'com.example.music',
          'name': 'Music',
          'platformId': 'com.example.music',
        },
        'isRunning': true,
        'cpu': {'label': 'CPU', 'value': 1.0, 'unit': '%', 'percent': 1.0},
        'memory': {'label': '内存', 'value': 12.0, 'unit': 'MB', 'percent': 1.0},
        'disk': {'label': '磁盘', 'value': 8.0, 'unit': 'MB', 'percent': 1.0},
        'network': {
          'label': '网络',
          'value': 0.0,
          'unit': 'KB/s',
          'percent': 0.0,
        },
        'sampledAt': '2026-05-16T09:30:00.000',
        'source': 'legacy',
      });

      final stoppedSnapshot = AppResourceSnapshot.fromJson({
        'app': {
          'id': 'com.example.notes',
          'name': 'Notes',
          'platformId': 'com.example.notes',
        },
        'isRunning': false,
        'cpu': {'label': 'CPU', 'value': 0.0, 'unit': '%', 'percent': 0.0},
        'memory': {'label': '内存', 'value': 0.0, 'unit': 'MB', 'percent': 0.0},
        'disk': {'label': '磁盘', 'value': 4.0, 'unit': 'MB', 'percent': 1.0},
        'network': {
          'label': '网络',
          'value': 0.0,
          'unit': 'KB/s',
          'percent': 0.0,
        },
        'sampledAt': '2026-05-16T09:30:00.000',
        'source': 'legacy',
      });

      expect(runningSnapshot.runState, AppRunState.background);
      expect(stoppedSnapshot.runState, AppRunState.stopped);
    });

    test('formats limited permission run states for display', () {
      final confirmed = _snapshotWithState(AppRunState.confirmed);
      final recentlyUsed = _snapshotWithState(AppRunState.recentlyUsed);
      final unknown = _snapshotWithState(AppRunState.unknown);

      expect(confirmed.statusLabel, '当前可确认');
      expect(recentlyUsed.statusLabel, '最近使用');
      expect(unknown.statusLabel, '未确认');
    });
  });
}

AppResourceSnapshot _snapshotWithState(AppRunState runState) {
  final isRunning = runState == AppRunState.confirmed;
  return AppResourceSnapshot(
    app: const MonitoredApp(
      id: 'com.example.demo',
      name: 'Demo',
      platformId: 'com.example.demo',
    ),
    isRunning: isRunning,
    runState: runState,
    cpu: const ResourceMetric(label: 'CPU', value: 0, unit: '%', percent: 0),
    memory: const ResourceMetric(label: '内存', value: 0, unit: 'MB', percent: 0),
    disk: const ResourceMetric(label: '磁盘', value: 0, unit: 'MB', percent: 0),
    network: const ResourceMetric(
      label: '网络',
      value: 0,
      unit: 'KB/s',
      percent: 0,
    ),
    sampledAt: DateTime(2026, 5, 16, 9, 30),
    source: 'test',
  );
}

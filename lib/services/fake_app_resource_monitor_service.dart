import 'dart:async';

import 'package:appresourcemonitor/models/app_resource_snapshot.dart';
import 'package:appresourcemonitor/models/monitored_app.dart';
import 'package:appresourcemonitor/models/resource_metric.dart';
import 'package:appresourcemonitor/services/app_resource_monitor_service.dart';

class FakeAppResourceMonitorService implements AppResourceMonitorService {
  FakeAppResourceMonitorService();

  static final _sampledAt = DateTime(2026, 5, 16, 9, 30);

  final List<AppResourceSnapshot> _snapshots = [
    AppResourceSnapshot(
      app: const MonitoredApp(
        id: 'com.example.maps',
        name: 'Maps',
        platformId: 'com.example.maps',
        iconHint: 'map',
      ),
      isRunning: true,
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
      sampledAt: _sampledAt,
      source: 'fake',
    ),
    AppResourceSnapshot(
      app: const MonitoredApp(
        id: 'com.example.mail',
        name: 'Mail',
        platformId: 'com.example.mail',
        iconHint: 'mail',
      ),
      isRunning: true,
      cpu: const ResourceMetric(
        label: 'CPU',
        value: 4.8,
        unit: '%',
        percent: 4.8,
      ),
      memory: const ResourceMetric(
        label: '内存',
        value: 248,
        unit: 'MB',
        percent: 12,
      ),
      disk: const ResourceMetric(
        label: '磁盘',
        value: 840,
        unit: 'MB',
        percent: 7,
      ),
      sampledAt: _sampledAt,
      source: 'fake',
    ),
    AppResourceSnapshot(
      app: const MonitoredApp(
        id: 'com.example.music',
        name: 'Music',
        platformId: 'com.example.music',
        iconHint: 'music',
      ),
      isRunning: false,
      cpu: const ResourceMetric(label: 'CPU', value: 0, unit: '%', percent: 0),
      memory: const ResourceMetric(
        label: '内存',
        value: 0,
        unit: 'MB',
        percent: 0,
      ),
      disk: const ResourceMetric(
        label: '磁盘',
        value: 2.4,
        unit: 'GB',
        percent: 18,
      ),
      sampledAt: _sampledAt,
      source: 'fake',
    ),
    AppResourceSnapshot(
      app: const MonitoredApp(
        id: 'com.example.browser',
        name: 'Browser',
        platformId: 'com.example.browser',
        iconHint: 'browser',
      ),
      isRunning: true,
      cpu: const ResourceMetric(
        label: 'CPU',
        value: 22.1,
        unit: '%',
        percent: 22.1,
      ),
      memory: const ResourceMetric(
        label: '内存',
        value: 768,
        unit: 'MB',
        percent: 36,
      ),
      disk: const ResourceMetric(
        label: '磁盘',
        value: 3.1,
        unit: 'GB',
        percent: 24,
      ),
      sampledAt: _sampledAt,
      source: 'fake',
    ),
  ];

  @override
  Future<AppResourceSnapshot?> getSnapshot(String appId) async {
    return _snapshots.where((snapshot) => snapshot.app.id == appId).firstOrNull;
  }

  @override
  Future<List<AppResourceSnapshot>> getSnapshots() async {
    return List<AppResourceSnapshot>.unmodifiable(_snapshots);
  }

  @override
  Stream<List<AppResourceSnapshot>> watchSnapshots() {
    return Stream<List<AppResourceSnapshot>>.value(
      List<AppResourceSnapshot>.unmodifiable(_snapshots),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';
import 'package:appresourcemonitor/models/MonitoredApp.dart';
import 'package:appresourcemonitor/models/ResourceMetric.dart';
import 'package:appresourcemonitor/services/AppResourceMonitorService.dart';

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
      runState: AppRunState.foreground,
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
      runState: AppRunState.background,
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
      network: const ResourceMetric(
        label: '网络',
        value: 42,
        unit: 'KB/s',
        percent: 4.2,
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
      runState: AppRunState.stopped,
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
      network: const ResourceMetric(
        label: '网络',
        value: 0,
        unit: 'KB/s',
        percent: 0,
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
      runState: AppRunState.background,
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
      network: const ResourceMetric(
        label: '网络',
        value: 256,
        unit: 'KB/s',
        percent: 25.6,
      ),
      sampledAt: _sampledAt,
      source: 'fake',
    ),
    AppResourceSnapshot(
      app: const MonitoredApp(
        id: 'com.example.camera',
        name: 'Camera',
        platformId: 'com.example.camera',
        iconHint: 'camera',
      ),
      isRunning: true,
      runState: AppRunState.confirmed,
      cpu: const ResourceMetric(
        label: 'CPU',
        value: 1.2,
        unit: '%',
        percent: 1.2,
      ),
      memory: const ResourceMetric(
        label: '内存',
        value: 96,
        unit: 'MB',
        percent: 5,
      ),
      disk: const ResourceMetric(
        label: '磁盘',
        value: 320,
        unit: 'MB',
        percent: 3,
      ),
      network: const ResourceMetric(
        label: '网络',
        value: 0,
        unit: 'KB/s',
        percent: 0,
      ),
      sampledAt: _sampledAt,
      source: 'fake:limited',
    ),
    AppResourceSnapshot(
      app: const MonitoredApp(
        id: 'com.example.reader',
        name: 'Reader',
        platformId: 'com.example.reader',
        iconHint: 'reader',
      ),
      isRunning: false,
      runState: AppRunState.recentlyUsed,
      cpu: const ResourceMetric(label: 'CPU', value: 0, unit: '%', percent: 0),
      memory: const ResourceMetric(
        label: '内存',
        value: 0,
        unit: 'MB',
        percent: 0,
      ),
      disk: const ResourceMetric(
        label: '磁盘',
        value: 180,
        unit: 'MB',
        percent: 2,
      ),
      network: const ResourceMetric(
        label: '网络',
        value: 0,
        unit: 'KB/s',
        percent: 0,
      ),
      sampledAt: _sampledAt,
      source: 'fake:limited',
    ),
    AppResourceSnapshot(
      app: const MonitoredApp(
        id: 'com.example.notes',
        name: 'Notes',
        platformId: 'com.example.notes',
        iconHint: 'notes',
      ),
      isRunning: false,
      runState: AppRunState.unknown,
      cpu: const ResourceMetric(label: 'CPU', value: 0, unit: '%', percent: 0),
      memory: const ResourceMetric(
        label: '内存',
        value: 0,
        unit: 'MB',
        percent: 0,
      ),
      disk: const ResourceMetric(
        label: '磁盘',
        value: 96,
        unit: 'MB',
        percent: 1,
      ),
      network: const ResourceMetric(
        label: '网络',
        value: 0,
        unit: 'KB/s',
        percent: 0,
      ),
      sampledAt: _sampledAt,
      source: 'fake:limited',
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
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

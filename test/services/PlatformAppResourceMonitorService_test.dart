import 'package:appresourcemonitor/models/ActionResult.dart';
import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';
import 'package:appresourcemonitor/models/MonitoredApp.dart';
import 'package:appresourcemonitor/models/ResourceMetric.dart';
import 'package:appresourcemonitor/platform/PlatformResourceBridge.dart';
import 'package:appresourcemonitor/services/PlatformAppResourceMonitorService.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlatformAppResourceMonitorService', () {
    test('returns snapshots from the platform bridge', () async {
      final snapshot = AppResourceSnapshot(
        app: const MonitoredApp(
          id: 'com.example.chat',
          name: 'Chat',
          platformId: 'com.example.chat',
        ),
        isRunning: true,
        runState: AppRunState.background,
        cpu: const ResourceMetric(
          label: 'CPU',
          value: 3.5,
          unit: '%',
          percent: 3.5,
        ),
        memory: const ResourceMetric(
          label: '内存',
          value: 42,
          unit: 'MB',
          percent: 4.2,
        ),
        disk: const ResourceMetric(
          label: '磁盘',
          value: 24,
          unit: 'MB',
          percent: 2.4,
        ),
        network: const ResourceMetric(
          label: '网络',
          value: 16,
          unit: 'KB/s',
          percent: 1.6,
        ),
        sampledAt: DateTime(2026, 5, 16, 9, 30),
        source: 'android:/proc+TrafficStats',
      );
      final service = PlatformAppResourceMonitorService(
        bridge: _FakePlatformResourceBridge([snapshot]),
      );

      final snapshots = await service.getSnapshots();
      final selected = await service.getSnapshot('com.example.chat');

      expect(snapshots, [snapshot]);
      expect(selected, snapshot);
    });
  });
}

class _FakePlatformResourceBridge implements PlatformResourceBridge {
  _FakePlatformResourceBridge(this.snapshots);

  final List<AppResourceSnapshot> snapshots;

  @override
  Future<List<AppResourceSnapshot>> fetchSnapshots() async => snapshots;

  @override
  Future<ActionResult> stopBackground(MonitoredApp app) {
    throw UnimplementedError();
  }

  @override
  Future<ActionResult> uninstall(MonitoredApp app) {
    throw UnimplementedError();
  }
}

import 'package:appresourcemonitor/models/app_resource_snapshot.dart';
import 'package:appresourcemonitor/models/monitored_app.dart';
import 'package:appresourcemonitor/models/resource_metric.dart';
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
        sampledAt: DateTime(2026, 5, 16, 9, 30),
        source: 'fake',
      );

      expect(snapshot.statusLabel, '运行中');
      expect(snapshot.cpu.displayValue, '12.5%');
      expect(snapshot.memory.displayValue, '512.0 MB');
      expect(snapshot.disk.displayValue, '1.2 GB');
    });
  });
}

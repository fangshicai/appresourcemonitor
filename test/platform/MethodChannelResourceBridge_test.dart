import 'package:appresourcemonitor/models/ActionResult.dart';
import 'package:appresourcemonitor/models/MonitoredApp.dart';
import 'package:appresourcemonitor/platform/MethodChannelResourceBridge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelResourceBridge', () {
    const channel = MethodChannel('app_resource_monitor/methods');

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('maps Android snapshots including network rate', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'fetchSnapshots');
            return <Map<String, Object?>>[
              <String, Object?>{
                'app': <String, Object?>{
                  'id': 'com.example.chat',
                  'name': 'Chat',
                  'platformId': 'com.example.chat',
                  'iconHint': 'android',
                },
                'isRunning': true,
                'runState': 'background',
                'cpu': <String, Object?>{
                  'label': 'CPU',
                  'value': 3.5,
                  'unit': '%',
                  'percent': 3.5,
                },
                'memory': <String, Object?>{
                  'label': '内存',
                  'value': 42.0,
                  'unit': 'MB',
                  'percent': 4.2,
                },
                'disk': <String, Object?>{
                  'label': '磁盘',
                  'value': 24.0,
                  'unit': 'MB',
                  'percent': 2.4,
                },
                'network': <String, Object?>{
                  'label': '网络',
                  'value': 16.0,
                  'unit': 'KB/s',
                  'percent': 1.6,
                },
                'sampledAt': '2026-05-16T09:30:00.000',
                'source': 'android:/proc+TrafficStats',
              },
            ];
          });

      final snapshots = await const MethodChannelResourceBridge()
          .fetchSnapshots();

      expect(snapshots, hasLength(1));
      expect(snapshots.single.app.platformId, 'com.example.chat');
      expect(snapshots.single.statusLabel, '后台运行');
      expect(snapshots.single.network.displayValue, '16.0 KB/s');
      expect(snapshots.single.source, 'android:/proc+TrafficStats');
    });

    test(
      'reports unavailable platform when fetchSnapshots is not registered',
      () {
        expect(
          const MethodChannelResourceBridge().fetchSnapshots(),
          throwsA(isA<PlatformResourceBridgeUnavailableException>()),
        );
      },
    );

    test('maps uninstall fallback as successful system entry launch', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'uninstall');
            return <String, Object?>{
              'status': 'success',
              'message': '已打开系统卸载入口；普通环境不支持静默卸载。',
            };
          });

      final result = await const MethodChannelResourceBridge().uninstall(
        const MonitoredApp(
          id: 'com.example.shop',
          name: 'Shop',
          platformId: 'com.example.shop',
        ),
      );

      expect(result.status, AppActionStatus.success);
      expect(result.message, contains('系统卸载入口'));
    });
  });
}

import 'package:appresourcemonitor/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('app_resource_monitor/methods');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    Get.reset();
  });

  testWidgets('shows dashboard with resource snapshots', (tester) async {
    var fetchCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method != 'fetchSnapshots') {
            return null;
          }
          fetchCount += 1;

          return <Map<String, Object?>>[
            <String, Object?>{
              'app': <String, Object?>{
                'id': 'com.example.maps',
                'name': 'Maps',
                'platformId': 'com.example.maps',
                'iconHint': 'android',
              },
              'isRunning': true,
              'cpu': <String, Object?>{
                'label': 'CPU',
                'value': 12.5,
                'unit': '%',
                'percent': 12.5,
              },
              'memory': <String, Object?>{
                'label': '内存',
                'value': 512.0,
                'unit': 'MB',
                'percent': 25.0,
              },
              'disk': <String, Object?>{
                'label': '磁盘',
                'value': 120.0,
                'unit': 'MB',
                'percent': 12.0,
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

    await tester.pumpWidget(const AppResourceMonitorApp());
    await tester.pumpAndSettle();

    expect(find.text('资源监控'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('CPU'), findsWidgets);
    expect(find.text('内存'), findsWidgets);
    expect(find.text('磁盘'), findsWidgets);
    expect(find.text('网络'), findsWidgets);

    await tester.enterText(find.byType(EditableText), 'map');
    await tester.pumpAndSettle();

    expect(find.text('Maps'), findsOneWidget);

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();
    expect(find.text('卸载'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(fetchCount, greaterThanOrEqualTo(2));
  });
}

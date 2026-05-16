import 'package:appresourcemonitor/models/action_result.dart';
import 'package:appresourcemonitor/models/app_resource_snapshot.dart';
import 'package:appresourcemonitor/models/monitored_app.dart';
import 'package:appresourcemonitor/platform/platform_resource_bridge.dart';
import 'package:flutter/services.dart';

class MethodChannelResourceBridge implements PlatformResourceBridge {
  const MethodChannelResourceBridge({
    MethodChannel methodChannel = const MethodChannel(_methodChannelName),
    EventChannel eventChannel = const EventChannel(_eventChannelName),
  }) : _methodChannel = methodChannel,
       _eventChannel = eventChannel;

  static const _methodChannelName = 'app_resource_monitor/methods';
  static const _eventChannelName = 'app_resource_monitor/snapshots';

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  @override
  Future<List<AppResourceSnapshot>> fetchSnapshots() async {
    final result =
        await _methodChannel.invokeListMethod<Map<dynamic, dynamic>>(
          'fetchSnapshots',
        ) ??
        <Map<dynamic, dynamic>>[];
    return result.map(_snapshotFromPlatformMap).toList(growable: false);
  }

  @override
  Stream<List<AppResourceSnapshot>> watchSnapshots() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      final list = event as List<dynamic>;
      return list
          .cast<Map<dynamic, dynamic>>()
          .map(_snapshotFromPlatformMap)
          .toList(growable: false);
    });
  }

  @override
  Future<ActionResult> stopBackground(MonitoredApp app) async {
    return _invokeAction('stopBackground', app, AppActionType.stopBackground);
  }

  @override
  Future<ActionResult> uninstall(MonitoredApp app) async {
    return _invokeAction('uninstall', app, AppActionType.uninstall);
  }

  Future<ActionResult> _invokeAction(
    String method,
    MonitoredApp app,
    AppActionType actionType,
  ) async {
    try {
      final result = await _methodChannel.invokeMapMethod<String, Object?>(
        method,
        app.toMap(),
      );
      return ActionResult(
        type: actionType,
        status: AppActionStatus.values.byName(
          result?['status'] as String? ?? AppActionStatus.unsupported.name,
        ),
        message: result?['message'] as String? ?? '当前平台未返回操作结果。',
      );
    } on MissingPluginException {
      return ActionResult(
        type: actionType,
        status: AppActionStatus.unsupported,
        message: '当前平台尚未接入原生资源监控能力。',
      );
    }
  }

  AppResourceSnapshot _snapshotFromPlatformMap(Map<dynamic, dynamic> value) {
    return AppResourceSnapshot.fromMap(
      value.map((key, mapValue) => MapEntry(key as String, mapValue)),
    );
  }
}

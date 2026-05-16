import 'package:appresourcemonitor/models/ActionResult.dart';
import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';
import 'package:appresourcemonitor/models/MonitoredApp.dart';
import 'package:appresourcemonitor/platform/PlatformResourceBridge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MethodChannelResourceBridge implements PlatformResourceBridge {
  const MethodChannelResourceBridge({
    MethodChannel methodChannel = const MethodChannel(_methodChannelName),
  }) : _methodChannel = methodChannel;

  static const _methodChannelName = 'app_resource_monitor/methods';

  final MethodChannel _methodChannel;

  @override
  Future<List<AppResourceSnapshot>> fetchSnapshots() async {
    debugPrint('[资源监控][Dart桥接] 开始调用原生 fetchSnapshots。');
    try {
      final result =
          await _methodChannel.invokeListMethod<Map<dynamic, dynamic>>(
            'fetchSnapshots',
          ) ??
          <Map<dynamic, dynamic>>[];
      debugPrint('[资源监控][Dart桥接] 原生 fetchSnapshots 返回 ${result.length} 条快照。');
      return result.map(_snapshotFromPlatformMap).toList(growable: false);
    } on MissingPluginException catch (error) {
      debugPrint(
        '[资源监控][Dart桥接] 未找到 fetchSnapshots 原生实现：$error。'
        '如果是在 Android 真机调试，请停止 App 后重新安装启动，不能只 hot reload。',
      );
      throw const PlatformResourceBridgeUnavailableException();
    } on PlatformException catch (error) {
      debugPrint('[资源监控][Dart桥接] 原生 fetchSnapshots 调用失败：$error');
      rethrow;
    }
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
    debugPrint('[资源监控][Dart桥接] 开始调用原生动作 $method：${app.platformId}。');
    try {
      final result = await _methodChannel.invokeMapMethod<String, Object?>(
        method,
        app.toJson(),
      );
      debugPrint(
        '[资源监控][Dart桥接] 原生动作 $method 返回：'
        'status=${result?['status']}，message=${result?['message']}。',
      );
      return ActionResult(
        type: actionType,
        status: AppActionStatus.values.byName(
          result?['status'] as String? ?? AppActionStatus.unsupported.name,
        ),
        message: result?['message'] as String? ?? '当前平台未返回操作结果。',
      );
    } on MissingPluginException catch (error) {
      debugPrint('[资源监控][Dart桥接] 未找到原生动作 $method 实现：$error');
      return ActionResult(
        type: actionType,
        status: AppActionStatus.unsupported,
        message: '当前平台尚未接入原生资源监控能力。',
      );
    } on PlatformException catch (error) {
      debugPrint('[资源监控][Dart桥接] 原生动作 $method 调用失败：$error');
      return ActionResult(
        type: actionType,
        status: AppActionStatus.failed,
        message: '原生操作失败：${error.message ?? error.code}',
      );
    }
  }

  AppResourceSnapshot _snapshotFromPlatformMap(Map<dynamic, dynamic> value) {
    return AppResourceSnapshot.fromJson(_normalizePlatformMap(value));
  }

  Map<String, dynamic> _normalizePlatformMap(Map<dynamic, dynamic> value) {
    return value.map((key, mapValue) {
      final normalizedValue = switch (mapValue) {
        Map<dynamic, dynamic>() => _normalizePlatformMap(mapValue),
        List<dynamic>() =>
          mapValue
              .map((item) {
                if (item is Map<dynamic, dynamic>) {
                  return _normalizePlatformMap(item);
                }
                return item;
              })
              .toList(growable: false),
        _ => mapValue,
      };
      return MapEntry(key as String, normalizedValue);
    });
  }
}

class PlatformResourceBridgeUnavailableException implements Exception {
  const PlatformResourceBridgeUnavailableException();

  String get message => '当前平台尚未接入原生资源监控能力。';

  @override
  String toString() => message;
}

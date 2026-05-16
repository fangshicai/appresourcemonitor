import 'package:appresourcemonitor/models/ActionResult.dart';
import 'package:appresourcemonitor/models/MonitoredApp.dart';
import 'package:appresourcemonitor/platform/PlatformResourceBridge.dart';
import 'package:appresourcemonitor/services/AppActionService.dart';

class PlatformAppActionService implements AppActionService {
  const PlatformAppActionService({required PlatformResourceBridge bridge})
    : _bridge = bridge;

  final PlatformResourceBridge _bridge;

  @override
  Future<ActionResult> stopBackground(MonitoredApp app) {
    return _bridge.stopBackground(app);
  }

  @override
  Future<ActionResult> uninstall(MonitoredApp app) {
    return _bridge.uninstall(app);
  }
}

import 'package:appresourcemonitor/models/ActionResult.dart';
import 'package:appresourcemonitor/models/MonitoredApp.dart';
import 'package:appresourcemonitor/services/AppActionService.dart';

class FakeAppActionService implements AppActionService {
  const FakeAppActionService();

  @override
  Future<ActionResult> stopBackground(MonitoredApp app) async {
    return ActionResult(
      type: AppActionType.stopBackground,
      status: AppActionStatus.permissionRequired,
      message: '${app.name} 需要 Root/Jailbreak 权限才能关闭后台。',
    );
  }

  @override
  Future<ActionResult> uninstall(MonitoredApp app) async {
    return ActionResult(
      type: AppActionType.uninstall,
      status: AppActionStatus.permissionRequired,
      message: '${app.name} 需要系统级权限或系统卸载入口。',
    );
  }
}

import 'package:appresourcemonitor/models/ActionResult.dart';
import 'package:appresourcemonitor/models/MonitoredApp.dart';

abstract interface class AppActionService {
  Future<ActionResult> stopBackground(MonitoredApp app);

  Future<ActionResult> uninstall(MonitoredApp app);
}

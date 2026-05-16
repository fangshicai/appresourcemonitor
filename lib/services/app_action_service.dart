import 'package:appresourcemonitor/models/action_result.dart';
import 'package:appresourcemonitor/models/monitored_app.dart';

abstract interface class AppActionService {
  Future<ActionResult> stopBackground(MonitoredApp app);

  Future<ActionResult> uninstall(MonitoredApp app);
}

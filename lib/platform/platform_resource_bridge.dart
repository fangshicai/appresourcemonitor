import 'package:appresourcemonitor/models/action_result.dart';
import 'package:appresourcemonitor/models/app_resource_snapshot.dart';
import 'package:appresourcemonitor/models/monitored_app.dart';

abstract interface class PlatformResourceBridge {
  Future<List<AppResourceSnapshot>> fetchSnapshots();

  Stream<List<AppResourceSnapshot>> watchSnapshots();

  Future<ActionResult> stopBackground(MonitoredApp app);

  Future<ActionResult> uninstall(MonitoredApp app);
}

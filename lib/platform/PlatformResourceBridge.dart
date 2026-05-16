import 'package:appresourcemonitor/models/ActionResult.dart';
import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';
import 'package:appresourcemonitor/models/MonitoredApp.dart';

abstract interface class PlatformResourceBridge {
  Future<List<AppResourceSnapshot>> fetchSnapshots();

  Future<ActionResult> stopBackground(MonitoredApp app);

  Future<ActionResult> uninstall(MonitoredApp app);
}

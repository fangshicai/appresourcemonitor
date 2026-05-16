import 'package:appresourcemonitor/models/app_resource_snapshot.dart';

abstract interface class AppResourceMonitorService {
  Future<List<AppResourceSnapshot>> getSnapshots();

  Future<AppResourceSnapshot?> getSnapshot(String appId);

  Stream<List<AppResourceSnapshot>> watchSnapshots();
}

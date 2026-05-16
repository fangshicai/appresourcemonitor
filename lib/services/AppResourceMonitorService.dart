import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';

abstract interface class AppResourceMonitorService {
  Future<List<AppResourceSnapshot>> getSnapshots();

  Future<AppResourceSnapshot?> getSnapshot(String appId);
}

import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';
import 'package:appresourcemonitor/platform/PlatformResourceBridge.dart';
import 'package:appresourcemonitor/services/AppResourceMonitorService.dart';

class PlatformAppResourceMonitorService implements AppResourceMonitorService {
  const PlatformAppResourceMonitorService({
    required PlatformResourceBridge bridge,
  }) : _bridge = bridge;

  final PlatformResourceBridge _bridge;

  @override
  Future<AppResourceSnapshot?> getSnapshot(String appId) async {
    final snapshots = await getSnapshots();
    return snapshots.where((snapshot) => snapshot.app.id == appId).firstOrNull;
  }

  @override
  Future<List<AppResourceSnapshot>> getSnapshots() {
    return _bridge.fetchSnapshots();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

import 'package:appresourcemonitor/models/app_resource_snapshot.dart';
import 'package:appresourcemonitor/services/app_resource_monitor_service.dart';
import 'package:get/get.dart';

enum MonitorViewStatus {
  loading,
  ready,
  empty,
  permissionRequired,
  unsupported,
  error,
}

class DashboardViewModel extends GetxController {
  DashboardViewModel({required AppResourceMonitorService monitorService})
    : _monitorService = monitorService;

  final AppResourceMonitorService _monitorService;

  final status = MonitorViewStatus.loading.obs;
  final snapshots = <AppResourceSnapshot>[].obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadSnapshots();
  }

  Future<void> loadSnapshots() async {
    status.value = MonitorViewStatus.loading;
    errorMessage.value = null;

    try {
      final loadedSnapshots = await _monitorService.getSnapshots();
      snapshots.assignAll(loadedSnapshots);
      status.value = loadedSnapshots.isEmpty
          ? MonitorViewStatus.empty
          : MonitorViewStatus.ready;
    } catch (error) {
      errorMessage.value = '资源快照加载失败：$error';
      status.value = MonitorViewStatus.error;
    }
  }
}

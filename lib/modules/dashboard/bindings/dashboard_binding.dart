import 'package:appresourcemonitor/modules/dashboard/view_models/dashboard_view_model.dart';
import 'package:appresourcemonitor/services/app_resource_monitor_service.dart';
import 'package:get/get.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardViewModel>(
      () => DashboardViewModel(
        monitorService: Get.find<AppResourceMonitorService>(),
      ),
    );
  }
}

import 'package:appresourcemonitor/modules/dashboard/view_models/DashboardViewModel.dart';
import 'package:appresourcemonitor/services/AppResourceMonitorService.dart';
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

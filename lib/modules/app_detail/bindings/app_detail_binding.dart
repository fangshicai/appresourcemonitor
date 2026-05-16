import 'package:appresourcemonitor/models/app_resource_snapshot.dart';
import 'package:appresourcemonitor/modules/app_detail/view_models/app_detail_view_model.dart';
import 'package:appresourcemonitor/services/app_action_service.dart';
import 'package:get/get.dart';

class AppDetailBinding extends Bindings {
  @override
  void dependencies() {
    final argument = Get.arguments;
    Get.lazyPut<AppDetailViewModel>(
      () => AppDetailViewModel(
        snapshot: argument is AppResourceSnapshot ? argument : null,
        actionService: Get.find<AppActionService>(),
      ),
    );
  }
}

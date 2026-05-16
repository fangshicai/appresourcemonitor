import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';
import 'package:appresourcemonitor/modules/app_detail/view_models/AppDetailViewModel.dart';
import 'package:appresourcemonitor/services/AppActionService.dart';
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

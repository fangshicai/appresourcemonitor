import 'package:appresourcemonitor/platform/method_channel_resource_bridge.dart';
import 'package:appresourcemonitor/platform/platform_resource_bridge.dart';
import 'package:appresourcemonitor/services/app_action_service.dart';
import 'package:appresourcemonitor/services/app_resource_monitor_service.dart';
import 'package:appresourcemonitor/services/fake_app_action_service.dart';
import 'package:appresourcemonitor/services/fake_app_resource_monitor_service.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PlatformResourceBridge>(
      const MethodChannelResourceBridge(),
      permanent: true,
    );
    Get.put<AppResourceMonitorService>(
      FakeAppResourceMonitorService(),
      permanent: true,
    );
    Get.put<AppActionService>(const FakeAppActionService(), permanent: true);
  }
}

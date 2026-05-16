import 'package:appresourcemonitor/platform/MethodChannelResourceBridge.dart';
import 'package:appresourcemonitor/platform/PlatformResourceBridge.dart';
import 'package:appresourcemonitor/services/AppActionService.dart';
import 'package:appresourcemonitor/services/AppResourceMonitorService.dart';
import 'package:appresourcemonitor/services/PlatformAppActionService.dart';
import 'package:appresourcemonitor/services/PlatformAppResourceMonitorService.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PlatformResourceBridge>(
      const MethodChannelResourceBridge(),
      permanent: true,
    );
    Get.put<AppResourceMonitorService>(
      PlatformAppResourceMonitorService(
        bridge: Get.find<PlatformResourceBridge>(),
      ),
      permanent: true,
    );
    Get.put<AppActionService>(
      PlatformAppActionService(bridge: Get.find<PlatformResourceBridge>()),
      permanent: true,
    );
  }
}

import 'package:appresourcemonitor/platform/MethodChannelResourceBridge.dart';
import 'package:appresourcemonitor/platform/PlatformResourceBridge.dart';
import 'package:appresourcemonitor/services/AppActionService.dart';
import 'package:appresourcemonitor/services/AppResourceMonitorService.dart';
import 'package:appresourcemonitor/services/FakeAppActionService.dart';
import 'package:appresourcemonitor/services/FakeAppResourceMonitorService.dart';
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

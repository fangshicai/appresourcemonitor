import 'package:appresourcemonitor/models/action_result.dart';
import 'package:appresourcemonitor/models/app_resource_snapshot.dart';
import 'package:appresourcemonitor/services/app_action_service.dart';
import 'package:get/get.dart';

class AppDetailViewModel extends GetxController {
  AppDetailViewModel({
    required AppResourceSnapshot? snapshot,
    required AppActionService actionService,
  }) : snapshot = Rxn<AppResourceSnapshot>(snapshot),
       _actionService = actionService;

  final Rxn<AppResourceSnapshot> snapshot;
  final AppActionService _actionService;
  final lastActionResult = Rxn<ActionResult>();
  final isActionRunning = false.obs;

  Future<void> stopBackground() async {
    final current = snapshot.value;
    if (current == null) {
      return;
    }
    await _runAction(() => _actionService.stopBackground(current.app));
  }

  Future<void> uninstall() async {
    final current = snapshot.value;
    if (current == null) {
      return;
    }
    await _runAction(() => _actionService.uninstall(current.app));
  }

  Future<void> _runAction(Future<ActionResult> Function() action) async {
    isActionRunning.value = true;
    try {
      lastActionResult.value = await action();
    } finally {
      isActionRunning.value = false;
    }
  }
}

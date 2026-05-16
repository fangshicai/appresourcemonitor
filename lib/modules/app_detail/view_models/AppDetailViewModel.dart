import 'package:appresourcemonitor/models/ActionResult.dart';
import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';
import 'package:appresourcemonitor/services/AppActionService.dart';
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

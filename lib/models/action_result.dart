enum AppActionType { stopBackground, uninstall }

enum AppActionStatus { success, failed, permissionRequired, unsupported }

class ActionResult {
  const ActionResult({
    required this.type,
    required this.status,
    required this.message,
  });

  final AppActionType type;
  final AppActionStatus status;
  final String message;

  bool get isSuccess => status == AppActionStatus.success;
}

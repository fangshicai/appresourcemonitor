import 'package:json_annotation/json_annotation.dart';

part 'ActionResult.g.dart';

enum AppActionType { stopBackground, uninstall }

enum AppActionStatus { success, failed, permissionRequired, unsupported }

@JsonSerializable()
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

  factory ActionResult.fromJson(Map<String, dynamic> json) =>
      _$ActionResultFromJson(json);

  Map<String, dynamic> toJson() => _$ActionResultToJson(this);
}

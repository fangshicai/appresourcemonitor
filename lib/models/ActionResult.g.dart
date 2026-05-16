// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ActionResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionResult _$ActionResultFromJson(Map<String, dynamic> json) => ActionResult(
  type: $enumDecode(_$AppActionTypeEnumMap, json['type']),
  status: $enumDecode(_$AppActionStatusEnumMap, json['status']),
  message: json['message'] as String,
);

Map<String, dynamic> _$ActionResultToJson(ActionResult instance) =>
    <String, dynamic>{
      'type': _$AppActionTypeEnumMap[instance.type]!,
      'status': _$AppActionStatusEnumMap[instance.status]!,
      'message': instance.message,
    };

const _$AppActionTypeEnumMap = {
  AppActionType.stopBackground: 'stopBackground',
  AppActionType.uninstall: 'uninstall',
};

const _$AppActionStatusEnumMap = {
  AppActionStatus.success: 'success',
  AppActionStatus.failed: 'failed',
  AppActionStatus.permissionRequired: 'permissionRequired',
  AppActionStatus.unsupported: 'unsupported',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ResourceMetric.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceMetric _$ResourceMetricFromJson(Map<String, dynamic> json) =>
    ResourceMetric(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      percent: (json['percent'] as num).toDouble(),
    );

Map<String, dynamic> _$ResourceMetricToJson(ResourceMetric instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
      'unit': instance.unit,
      'percent': instance.percent,
    };

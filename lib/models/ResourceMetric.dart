import 'package:json_annotation/json_annotation.dart';

part 'ResourceMetric.g.dart';

@JsonSerializable()
class ResourceMetric {
  const ResourceMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.percent,
  });

  final String label;
  final double value;
  final String unit;
  final double percent;

  String get displayValue {
    if (unit == '%') {
      return '${value.toStringAsFixed(1)}%';
    }
    return '${value.toStringAsFixed(1)} $unit';
  }

  factory ResourceMetric.fromJson(Map<String, dynamic> json) =>
      _$ResourceMetricFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceMetricToJson(this);
}

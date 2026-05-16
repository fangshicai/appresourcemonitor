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

  factory ResourceMetric.fromMap(Map<String, Object?> map) {
    return ResourceMetric(
      label: map['label'] as String,
      value: (map['value'] as num).toDouble(),
      unit: map['unit'] as String,
      percent: (map['percent'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() {
    return {'label': label, 'value': value, 'unit': unit, 'percent': percent};
  }
}

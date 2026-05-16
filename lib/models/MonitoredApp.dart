import 'package:json_annotation/json_annotation.dart';

part 'MonitoredApp.g.dart';

@JsonSerializable()
class MonitoredApp {
  const MonitoredApp({
    required this.id,
    required this.name,
    required this.platformId,
    this.iconHint,
  });

  final String id;
  final String name;
  final String platformId;
  final String? iconHint;

  factory MonitoredApp.fromJson(Map<String, dynamic> json) =>
      _$MonitoredAppFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoredAppToJson(this);
}

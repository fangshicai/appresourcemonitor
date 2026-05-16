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

  factory MonitoredApp.fromMap(Map<String, Object?> map) {
    return MonitoredApp(
      id: map['id'] as String,
      name: map['name'] as String,
      platformId: map['platformId'] as String,
      iconHint: map['iconHint'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'platformId': platformId,
      'iconHint': iconHint,
    };
  }
}

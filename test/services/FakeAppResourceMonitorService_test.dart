import 'package:appresourcemonitor/services/FakeAppResourceMonitorService.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeAppResourceMonitorService', () {
    test('returns deterministic resource snapshots', () async {
      final service = FakeAppResourceMonitorService();

      final snapshots = await service.getSnapshots();

      expect(snapshots, hasLength(4));
      expect(snapshots.first.app.name, 'Maps');
      expect(snapshots.first.isRunning, isTrue);
    });
  });
}

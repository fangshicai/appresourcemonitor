import 'package:appresourcemonitor/modules/dashboard/view_models/dashboard_view_model.dart';
import 'package:appresourcemonitor/services/fake_app_resource_monitor_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardViewModel', () {
    test('loads snapshots into ready state', () async {
      final viewModel = DashboardViewModel(
        monitorService: FakeAppResourceMonitorService(),
      );

      await viewModel.loadSnapshots();

      expect(viewModel.status.value, MonitorViewStatus.ready);
      expect(viewModel.snapshots, isNotEmpty);
      expect(viewModel.errorMessage.value, isNull);
    });
  });
}

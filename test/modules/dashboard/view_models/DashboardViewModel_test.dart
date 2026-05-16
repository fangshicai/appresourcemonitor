import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';
import 'package:appresourcemonitor/modules/dashboard/view_models/DashboardViewModel.dart';
import 'package:appresourcemonitor/platform/MethodChannelResourceBridge.dart';
import 'package:appresourcemonitor/services/AppResourceMonitorService.dart';
import 'package:appresourcemonitor/services/FakeAppResourceMonitorService.dart';
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

    test('filters snapshots by app name or package id', () async {
      final viewModel = DashboardViewModel(
        monitorService: FakeAppResourceMonitorService(),
      );

      await viewModel.loadSnapshots();
      viewModel.updateSearchQuery('mail');

      expect(viewModel.snapshots, hasLength(1));
      expect(viewModel.snapshots.single.app.name, 'Mail');

      viewModel.updateSearchQuery('com.example.browser');

      expect(viewModel.snapshots, hasLength(1));
      expect(viewModel.snapshots.single.app.name, 'Browser');
    });

    test('sorts snapshots by selected resource in descending order', () async {
      final viewModel = DashboardViewModel(
        monitorService: FakeAppResourceMonitorService(),
      );

      await viewModel.loadSnapshots();
      viewModel.updateSortOption(DashboardSortOption.memory);

      expect(viewModel.snapshots.first.app.name, 'Browser');

      viewModel.updateSortOption(DashboardSortOption.cpu);

      expect(viewModel.snapshots.first.app.name, 'Browser');
      expect(viewModel.sortOption.value, DashboardSortOption.cpu);
    });

    test('filters snapshots by running state', () async {
      final viewModel = DashboardViewModel(
        monitorService: FakeAppResourceMonitorService(),
      );

      await viewModel.loadSnapshots();
      viewModel.updateRunningFilter(DashboardRunningFilter.running);

      expect(viewModel.snapshots, isNotEmpty);
      expect(
        viewModel.snapshots.every((snapshot) => snapshot.isRunning),
        isTrue,
      );

      viewModel.updateRunningFilter(DashboardRunningFilter.stopped);

      expect(viewModel.snapshots, hasLength(1));
      expect(viewModel.snapshots.single.app.name, 'Music');
      expect(viewModel.runningFilter.value, DashboardRunningFilter.stopped);
    });

    test('filters snapshots by background running state', () async {
      final viewModel = DashboardViewModel(
        monitorService: FakeAppResourceMonitorService(),
      );

      await viewModel.loadSnapshots();
      viewModel.updateRunningFilter(DashboardRunningFilter.background);

      expect(viewModel.snapshots, isNotEmpty);
      expect(
        viewModel.snapshots.every(
          (snapshot) => snapshot.runState == AppRunState.background,
        ),
        isTrue,
      );
      expect(viewModel.snapshots.map((snapshot) => snapshot.app.name), [
        'Browser',
        'Mail',
      ]);
    });

    test('filters limited permission snapshot states', () async {
      final viewModel = DashboardViewModel(
        monitorService: FakeAppResourceMonitorService(),
      );

      await viewModel.loadSnapshots();
      viewModel.updateRunningFilter(DashboardRunningFilter.confirmed);

      expect(viewModel.snapshots.map((snapshot) => snapshot.runState), [
        AppRunState.confirmed,
      ]);

      viewModel.updateRunningFilter(DashboardRunningFilter.recentlyUsed);

      expect(viewModel.snapshots.map((snapshot) => snapshot.runState), [
        AppRunState.recentlyUsed,
      ]);

      viewModel.updateRunningFilter(DashboardRunningFilter.unknown);

      expect(viewModel.snapshots.map((snapshot) => snapshot.runState), [
        AppRunState.unknown,
      ]);
    });

    test(
      'shows unsupported state when native snapshot channel is missing',
      () async {
        final viewModel = DashboardViewModel(
          monitorService: _UnavailableMonitorService(),
        );

        await viewModel.loadSnapshots();

        expect(viewModel.status.value, MonitorViewStatus.unsupported);
        expect(viewModel.errorMessage.value, '当前平台尚未接入原生资源监控能力。');
      },
    );

    testWidgets(
      'auto refreshes snapshots every second without showing loading',
      (tester) async {
        final monitorService = _CountingMonitorService();
        final viewModel = DashboardViewModel(monitorService: monitorService);

        viewModel.onInit();
        await tester.pump();

        expect(monitorService.callCount, 1);
        expect(viewModel.status.value, MonitorViewStatus.ready);

        await tester.pump(const Duration(seconds: 1));
        await tester.pump();

        expect(monitorService.callCount, 2);
        expect(viewModel.status.value, MonitorViewStatus.ready);

        viewModel.onClose();
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();

        expect(monitorService.callCount, 2);
      },
    );
  });
}

class _CountingMonitorService implements AppResourceMonitorService {
  int callCount = 0;

  @override
  Future<AppResourceSnapshot?> getSnapshot(String appId) async {
    return null;
  }

  @override
  Future<List<AppResourceSnapshot>> getSnapshots() async {
    callCount += 1;
    return FakeAppResourceMonitorService().getSnapshots();
  }
}

class _UnavailableMonitorService implements AppResourceMonitorService {
  @override
  Future<AppResourceSnapshot?> getSnapshot(String appId) {
    throw const PlatformResourceBridgeUnavailableException();
  }

  @override
  Future<List<AppResourceSnapshot>> getSnapshots() {
    throw const PlatformResourceBridgeUnavailableException();
  }
}

import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';
import 'package:appresourcemonitor/models/ResourceMetric.dart';
import 'package:appresourcemonitor/platform/MethodChannelResourceBridge.dart';
import 'package:appresourcemonitor/services/AppResourceMonitorService.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum MonitorViewStatus {
  loading,
  ready,
  empty,
  permissionRequired,
  unsupported,
  error,
}

enum DashboardSortOption { appName, cpu, memory, disk, network }

enum DashboardRunningFilter { all, running, stopped }

class DashboardViewModel extends GetxController {
  DashboardViewModel({required AppResourceMonitorService monitorService})
    : _monitorService = monitorService;

  final AppResourceMonitorService _monitorService;
  final List<AppResourceSnapshot> _allSnapshots = <AppResourceSnapshot>[];

  final status = MonitorViewStatus.loading.obs;
  final snapshots = <AppResourceSnapshot>[].obs;
  final errorMessage = RxnString();
  final searchQuery = ''.obs;
  final sortOption = DashboardSortOption.appName.obs;
  final runningFilter = DashboardRunningFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    loadSnapshots();
  }

  Future<void> loadSnapshots() async {
    debugPrint('[资源监控][首页] 开始加载资源快照。');
    status.value = MonitorViewStatus.loading;
    errorMessage.value = null;

    try {
      final loadedSnapshots = await _monitorService.getSnapshots();
      _allSnapshots
        ..clear()
        ..addAll(loadedSnapshots);
      _applyFiltersAndSorting();
      status.value = loadedSnapshots.isEmpty
          ? MonitorViewStatus.empty
          : MonitorViewStatus.ready;
      debugPrint(
        '[资源监控][首页] 资源快照加载完成：${loadedSnapshots.length} 条，'
        '页面状态=${status.value.name}。',
      );
    } on PlatformResourceBridgeUnavailableException catch (error) {
      _allSnapshots.clear();
      snapshots.clear();
      errorMessage.value = error.message;
      status.value = MonitorViewStatus.unsupported;
      debugPrint('[资源监控][首页] 原生资源监控通道不可用：${error.message}');
    } catch (error) {
      _allSnapshots.clear();
      snapshots.clear();
      errorMessage.value = '资源快照加载失败：$error';
      status.value = MonitorViewStatus.error;
      debugPrint('[资源监控][首页] 资源快照加载失败：$error');
    }
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
    _applyFiltersAndSorting();
  }

  void updateSortOption(DashboardSortOption value) {
    sortOption.value = value;
    _applyFiltersAndSorting();
  }

  void updateRunningFilter(DashboardRunningFilter value) {
    runningFilter.value = value;
    _applyFiltersAndSorting();
  }

  void _applyFiltersAndSorting() {
    final normalizedQuery = searchQuery.value.trim().toLowerCase();
    final visibleSnapshots = _allSnapshots
        .where((snapshot) {
          final matchesRunningFilter = switch (runningFilter.value) {
            DashboardRunningFilter.all => true,
            DashboardRunningFilter.running => snapshot.isRunning,
            DashboardRunningFilter.stopped => !snapshot.isRunning,
          };
          if (!matchesRunningFilter) {
            return false;
          }

          if (normalizedQuery.isEmpty) {
            return true;
          }

          return snapshot.app.name.toLowerCase().contains(normalizedQuery) ||
              snapshot.app.platformId.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);

    visibleSnapshots.sort((left, right) {
      return switch (sortOption.value) {
        DashboardSortOption.appName => left.app.name.toLowerCase().compareTo(
          right.app.name.toLowerCase(),
        ),
        DashboardSortOption.cpu => _compareMetric(right.cpu, left.cpu),
        DashboardSortOption.memory => _compareMetric(right.memory, left.memory),
        DashboardSortOption.disk => _compareMetric(right.disk, left.disk),
        DashboardSortOption.network => _compareMetric(
          right.network,
          left.network,
        ),
      };
    });

    snapshots.assignAll(visibleSnapshots);
  }

  int _compareMetric(ResourceMetric left, ResourceMetric right) {
    return left.percent.compareTo(right.percent);
  }
}

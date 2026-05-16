import 'package:appresourcemonitor/app/routes/AppRoutes.dart';
import 'package:appresourcemonitor/models/AppResourceSnapshot.dart';
import 'package:appresourcemonitor/models/ResourceMetric.dart';
import 'package:appresourcemonitor/modules/dashboard/view_models/DashboardViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardPage extends GetView<DashboardViewModel> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资源监控'),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: controller.loadSnapshots,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        return switch (controller.status.value) {
          MonitorViewStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          MonitorViewStatus.empty => const Center(child: Text('暂无可监控应用')),
          MonitorViewStatus.permissionRequired => const Center(
            child: Text('需要 Root/Jailbreak 权限'),
          ),
          MonitorViewStatus.unsupported => const Center(
            child: Text('当前平台不支持资源监控'),
          ),
          MonitorViewStatus.error => Center(
            child: Text(controller.errorMessage.value ?? '资源监控失败'),
          ),
          MonitorViewStatus.ready => Column(
            children: [
              _DashboardControls(controller: controller),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.loadSnapshots,
                  child: controller.snapshots.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(16),
                          children: const [
                            SizedBox(height: 160),
                            Center(child: Text('没有匹配的应用')),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.snapshots.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _SnapshotCard(
                              snapshot: controller.snapshots[index],
                              onReturn: controller.loadSnapshots,
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        };
      }),
    );
  }
}

class _DashboardControls extends StatelessWidget {
  const _DashboardControls({required this.controller});

  final DashboardViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: controller.updateSearchQuery,
                  decoration: const InputDecoration(
                    hintText: '按名称或包名搜索',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() {
                return DropdownButton<DashboardSortOption>(
                  value: controller.sortOption.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.updateSortOption(value);
                    }
                  },
                  items: DashboardSortOption.values
                      .map((option) {
                        return DropdownMenuItem<DashboardSortOption>(
                          value: option,
                          child: Text(option.label),
                        );
                      })
                      .toList(growable: false),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<DashboardRunningFilter>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                selected: {controller.runningFilter.value},
                onSelectionChanged: (values) {
                  controller.updateRunningFilter(values.single);
                },
                segments: DashboardRunningFilter.values
                    .map((filter) {
                      return ButtonSegment<DashboardRunningFilter>(
                        value: filter,
                        label: Text(
                          filter.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({required this.snapshot, required this.onReturn});

  final AppResourceSnapshot snapshot;
  final Future<void> Function() onReturn;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Get.toNamed(AppRoutes.appDetail, arguments: snapshot);
          await onReturn();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(snapshot.app.name.characters.first)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.app.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(snapshot.app.platformId),
                      ],
                    ),
                  ),
                  Chip(label: Text(snapshot.statusLabel)),
                ],
              ),
              const SizedBox(height: 16),
              _MetricRow(metric: snapshot.cpu),
              _MetricRow(metric: snapshot.memory),
              _MetricRow(metric: snapshot.disk),
              _MetricRow(metric: snapshot.network),
            ],
          ),
        ),
      ),
    );
  }
}

extension _DashboardSortOptionLabel on DashboardSortOption {
  String get label {
    return switch (this) {
      DashboardSortOption.appName => '名称',
      DashboardSortOption.cpu => 'CPU',
      DashboardSortOption.memory => '内存',
      DashboardSortOption.disk => '磁盘',
      DashboardSortOption.network => '网络',
    };
  }
}

extension _DashboardRunningFilterLabel on DashboardRunningFilter {
  String get label {
    return switch (this) {
      DashboardRunningFilter.all => '全部',
      DashboardRunningFilter.running => '运行中',
      DashboardRunningFilter.background => '后台运行',
      DashboardRunningFilter.confirmed => '当前可确认',
      DashboardRunningFilter.recentlyUsed => '最近使用',
      DashboardRunningFilter.unknown => '未确认',
      DashboardRunningFilter.stopped => '未运行',
    };
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});

  final ResourceMetric metric;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text(metric.label)),
          Expanded(
            child: LinearProgressIndicator(
              value: (metric.percent / 100).clamp(0, 1),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            child: Text(metric.displayValue, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

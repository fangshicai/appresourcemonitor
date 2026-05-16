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
          MonitorViewStatus.ready => RefreshIndicator(
            onRefresh: controller.loadSnapshots,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.snapshots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _SnapshotCard(snapshot: controller.snapshots[index]);
              },
            ),
          ),
        };
      }),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({required this.snapshot});

  final AppResourceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.toNamed(AppRoutes.appDetail, arguments: snapshot),
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

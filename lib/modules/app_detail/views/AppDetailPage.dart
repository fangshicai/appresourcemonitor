import 'package:appresourcemonitor/models/ResourceMetric.dart';
import 'package:appresourcemonitor/modules/app_detail/view_models/AppDetailViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDetailPage extends GetView<AppDetailViewModel> {
  const AppDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final snapshot = controller.snapshot.value;
      if (snapshot == null) {
        return const Scaffold(body: Center(child: Text('未找到应用资源快照')));
      }

      return Scaffold(
        appBar: AppBar(title: Text(snapshot.app.name)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(snapshot.app.platformId),
            const SizedBox(height: 16),
            _MetricTile(metric: snapshot.cpu),
            _MetricTile(metric: snapshot.memory),
            _MetricTile(metric: snapshot.disk),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: controller.isActionRunning.value
                  ? null
                  : () => _confirm(
                      context,
                      title: '关闭后台',
                      message: '将尝试关闭 ${snapshot.app.name} 的后台进程。',
                      onConfirm: controller.stopBackground,
                    ),
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('关闭后台'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.isActionRunning.value
                  ? null
                  : () => _confirm(
                      context,
                      title: '卸载应用',
                      message: '卸载 ${snapshot.app.name} 可能不可恢复。',
                      onConfirm: controller.uninstall,
                    ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('卸载'),
            ),
            if (controller.lastActionResult.value != null) ...[
              const SizedBox(height: 16),
              Text(controller.lastActionResult.value!.message),
            ],
          ],
        ),
      );
    });
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确认'),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      await onConfirm();
    }
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final ResourceMetric metric;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(metric.label),
        subtitle: LinearProgressIndicator(
          value: (metric.percent / 100).clamp(0, 1),
        ),
        trailing: Text(metric.displayValue),
      ),
    );
  }
}

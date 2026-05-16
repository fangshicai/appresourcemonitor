import 'package:appresourcemonitor/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows dashboard with resource snapshots', (tester) async {
    await tester.pumpWidget(const AppResourceMonitorApp());
    await tester.pumpAndSettle();

    expect(find.text('资源监控'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('CPU'), findsWidgets);
    expect(find.text('内存'), findsWidgets);
    expect(find.text('磁盘'), findsWidgets);
  });
}

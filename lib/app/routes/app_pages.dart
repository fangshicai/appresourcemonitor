import 'package:appresourcemonitor/app/routes/app_routes.dart';
import 'package:appresourcemonitor/modules/app_detail/bindings/app_detail_binding.dart';
import 'package:appresourcemonitor/modules/app_detail/views/app_detail_page.dart';
import 'package:appresourcemonitor/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:appresourcemonitor/modules/dashboard/views/dashboard_page.dart';
import 'package:get/get.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.appDetail,
      page: () => const AppDetailPage(),
      binding: AppDetailBinding(),
    ),
  ];
}

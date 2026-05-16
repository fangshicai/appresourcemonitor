import 'package:appresourcemonitor/app/routes/AppRoutes.dart';
import 'package:appresourcemonitor/modules/app_detail/bindings/AppDetailBinding.dart';
import 'package:appresourcemonitor/modules/app_detail/views/AppDetailPage.dart';
import 'package:appresourcemonitor/modules/dashboard/bindings/DashboardBinding.dart';
import 'package:appresourcemonitor/modules/dashboard/views/DashboardPage.dart';
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

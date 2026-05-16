import 'package:appresourcemonitor/app/bindings/initial_binding.dart';
import 'package:appresourcemonitor/app/routes/app_pages.dart';
import 'package:appresourcemonitor/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppResourceMonitorApp extends StatelessWidget {
  const AppResourceMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'App Resource Monitor',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.dashboard,
      getPages: AppPages.pages,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
    );
  }
}

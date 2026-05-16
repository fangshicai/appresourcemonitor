import 'package:appresourcemonitor/app/bindings/InitialBinding.dart';
import 'package:appresourcemonitor/app/routes/AppPages.dart';
import 'package:appresourcemonitor/app/routes/AppRoutes.dart';
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

// ignore_for_file: depend_on_referenced_packages, avoid_print, library_private_types_in_public_api
import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hartono_booth/app/routes/app_pages.dart';
import 'package:hartono_booth/app/core/provider/api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: "Hartono Booth",
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          initialBinding: BindingsBuilder(() {
            Get.put(Api(), permanent: true);
          }),
        );
      },
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:hartono_booth/app/modules/camera/bindings/camera_binding.dart';
import 'package:hartono_booth/app/modules/camera/views/camera_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.CAMERA,
      page: () => const PageCameraView(),
      binding: PageCameraBinding(),
    ),
  ];
}

import 'package:get/get.dart';
import 'package:hartono_booth/app/modules/camera/controllers/camera_controller.dart';

class PageCameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PageCameraController>(
      () => PageCameraController(),
    );
  }
}

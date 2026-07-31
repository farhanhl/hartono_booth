import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hartono_booth/app/widgets/loading_animation.dart';
import '../controllers/camera_controller.dart';

class PageCameraView extends GetView<PageCameraController> {
  const PageCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PageCameraController>(
      init: PageCameraController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: const Text("Camera"),
          ),
          body: controller.isCameraInitialized &&
                  controller.cameraController != null
              ? SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: CameraPreview(controller.cameraController!))
              : SharedWidgets.loadingAnimation(
                  color: Colors.black,
                  size: 100.sp,
                ),
        );
      },
    );
  }
}

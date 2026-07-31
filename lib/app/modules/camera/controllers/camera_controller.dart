// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, depend_on_referenced_packages

import 'package:camera/camera.dart';
import 'package:get/get.dart';

class PageCameraController extends GetxController {
  CameraController? cameraController;
  late List<CameraDescription> cameras;
  bool isCameraInitialized = false;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await cameraController!.initialize();
      isCameraInitialized = true;
      update();
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}

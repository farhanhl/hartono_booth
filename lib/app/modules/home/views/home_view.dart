import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hartono_booth/app/core/provider/api.dart';
import 'package:hartono_booth/app/modules/home/services/home_services.dart';
import 'package:hartono_booth/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hartono_booth/app/widgets/loading_animation.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(HomeServices(Get.find<Api>())),
      builder: (controller) {
        return Scaffold(
          floatingActionButton: SpeedDial(
            icon: Icons.more_vert,
            backgroundColor: const Color(0XFFFDCB00),
            foregroundColor: const Color(0XFF323840),
            children: [
              SpeedDialChild(
                child: const Icon(Icons.refresh),
                label: 'Segarkan Halaman',
                backgroundColor: const Color(0XFF1C8BCA),
                onTap: () => controller.webViewController.reload(),
              ),
              SpeedDialChild(
                child: const Icon(Icons.camera),
                label: 'Camera',
                backgroundColor: Colors.orange,
                onTap: () => Get.toNamed(Routes.CAMERA),
              ),
              SpeedDialChild(
                child: const Icon(Icons.refresh),
                label: 'Coba Lagi',
                backgroundColor: Colors.red,
                onTap: () => controller.onInit(),
              ),
            ],
          ),
          body: controller.isLoading == true
              ? SharedWidgets.loadingAnimation(
                  color: Colors.black,
                  size: 100.sp,
                )
              : SafeArea(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(controller.webUrl),
                    ),
                    onReceivedServerTrustAuthRequest:
                        (controller, challenge) async {
                      return ServerTrustAuthResponse(
                        action: ServerTrustAuthResponseAction.PROCEED,
                      );
                    },
                    onWebViewCreated: (controller) {
                      this.controller.webViewController = controller;
                    },
                    initialSettings: InAppWebViewSettings(
                      useHybridComposition: true,
                      javaScriptEnabled: true,
                      mediaPlaybackRequiresUserGesture: false,
                      cacheEnabled: false,
                      clearCache: true,
                    ),
                    onPermissionRequest: (controller, permissionRequest) async {
                      return Future.value(
                        PermissionResponse(
                          resources: permissionRequest.resources,
                          action: PermissionResponseAction.GRANT,
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}

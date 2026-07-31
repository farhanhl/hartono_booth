import 'package:get/get.dart';
import 'package:hartono_booth/app/core/provider/api.dart';
import 'package:hartono_booth/app/modules/home/services/home_services.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        HomeServices(
          Get.find<Api>(),
        ),
      ),
    );
  }
}

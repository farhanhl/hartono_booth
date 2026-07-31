import 'package:hartono_booth/app/core/provider/api.dart';
import 'package:hartono_booth/app/modules/home/models/config_model.dart';
import 'package:hartono_booth/app/modules/home/models/change_app_status_request_model.dart';

class HomeServices {
  Api api;
  HomeServices(this.api);

  Future<dynamic> handleAppStatus(ChangeAppStatusRequest request) {
    return api.handleAppStatus(request).then((value) {
      return value.data;
    }).catchError(
      (e) {
        throw e;
      },
    );
  }

  Future<ConfigModel> getAppConfig() {
    return api.getAppConfig().then((value) {
      return ConfigModel.fromJson(value.data);
    }).catchError(
      (e) {
        throw e;
      },
    );
  }
}

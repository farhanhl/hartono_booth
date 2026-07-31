import 'package:dio/dio.dart';
import 'package:hartono_booth/app/modules/home/models/change_app_status_request_model.dart';

const baseUrl = "https://api-hartono.dmmrnd.id";

class Api extends Interceptor {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
    ),
  );

  Future<Response> handleAppStatus(ChangeAppStatusRequest closeData) async {
    return dio.post("/device/change-status", data: closeData);
  }

  Future<Response> getAppConfig() async {
    return dio.get("/display/booth/config");
  }
}

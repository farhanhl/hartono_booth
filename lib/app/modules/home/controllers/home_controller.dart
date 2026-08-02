// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import 'package:hartono_booth/app/modules/home/models/config_model.dart';
import 'package:flutter/material.dart';
import 'package:android_id/android_id.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hartono_booth/app/modules/home/models/change_app_status_request_model.dart';
import 'package:hartono_booth/app/modules/home/services/home_services.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  String? deviceId;
  String webUrl = "";
  final HomeServices services;
  bool isLoading = false;
  String? initError;
  late InAppWebViewController webViewController;
  final AndroidId androidIdPlugin = const AndroidId();
  ChangeAppStatusRequest changeAppRequest = ChangeAppStatusRequest();
  ConfigModel configModel = ConfigModel();

  static const int _maxRetries = 10;

  HomeController(this.services);

  @override
  void onInit() {
    super.onInit();
    _initializeUntilSuccess();
  }

  Future<void> _initializeUntilSuccess() async {
    isLoading = true;
    initError = null;
    update();

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        await _fetchConfig();
        break;
      } catch (e) {
        print("❌ Inisialisasi gagal (attempt $attempt/$_maxRetries): $e");
        if (attempt == _maxRetries) {
          initError = "Gagal menghubungi server. Periksa koneksi internet.";
          print("❌ Max retry tercapai, berhenti mencoba.");
        } else {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }

    isLoading = false;
    update();

    if (initError == null) {
      await _setupAfterConfig();
      await handleAppOpen();
    }
  }

  Future<void> _fetchConfig() async {
    configModel = await services.getAppConfig();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> requestCameraPermission() async {
    try {
      if (await Permission.camera.isDenied) {
        await Permission.camera.request();
      }
      if (await Permission.microphone.isDenied) {
        await Permission.microphone.request();
      }
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      print("⚠️ Gagal request permission: $e");
    }
  }

  Future<void> getAndroidId() async {
    try {
      deviceId = await androidIdPlugin.getId();
      if (deviceId == null || deviceId!.isEmpty) {
        print("⚠️ Android ID null, menggunakan fallback");
        deviceId = "unknown_device";
      }
    } catch (e) {
      print("⚠️ Gagal mendapatkan Android ID: $e, menggunakan fallback");
      deviceId = "unknown_device";
    }
  }

  Future<void> _setupAfterConfig() async {
    try {
      await requestCameraPermission();
    } catch (e) {
      print("⚠️ Permission error, lanjut: $e");
    }

    try {
      await getAndroidId();
    } catch (e) {
      print("⚠️ Device ID error, lanjut: $e");
    }

    webUrl = "${configModel.result?.url ?? ''}$deviceId";

    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (e) {
      print("⚠️ Observer already added: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      print("📴 App closing or inactive");
      await handleAppClose();
    } else if (state == AppLifecycleState.resumed) {
      await handleAppOpen();
    }
  }

  Future<void> handleAppClose() async {
    changeAppRequest = ChangeAppStatusRequest(deviceId: deviceId, status: 0);
    try {
      await services.handleAppStatus(changeAppRequest);
      print("✅ Status aplikasi: CLOSED");
    } catch (e) {
      print("❌ Gagal update status CLOSE: $e");
    }
  }

  Future<void> handleAppOpen() async {
    changeAppRequest = ChangeAppStatusRequest(deviceId: deviceId, status: 1);
    try {
      await services.handleAppStatus(changeAppRequest);
      print("✅ Status aplikasi: OPEN");
    } catch (e) {
      print("❌ Gagal update status OPEN: $e");
    }
  }
}

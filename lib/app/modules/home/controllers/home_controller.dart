// ignore_for_file: avoid_print

import 'dart:async';
import 'package:get/get.dart';
import 'package:hartono_booth/app/modules/home/models/config_model.dart';
import 'package:flutter/material.dart';
import 'package:android_id/android_id.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hartono_booth/app/modules/home/models/change_app_status_request_model.dart';
import 'package:hartono_booth/app/modules/home/services/home_services.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  String? deviceId;
  String webUrl = "";
  final HomeServices services;
  bool isLoading = false;
  final FlutterTts flutterTts = FlutterTts();
  late InAppWebViewController webViewController;
  final AndroidId androidIdPlugin = const AndroidId();
  ChangeAppStatusRequest changeAppRequest = ChangeAppStatusRequest();
  final String url =
      'https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=1308207&key=69114d1203ad42fb16f65ae74f2ad8e224c61deb';
  ConfigModel configModel = ConfigModel();

  HomeController(this.services);

  @override
  void onInit() {
    super.onInit();
    _initializeUntilSuccess();
  }

  void _initializeUntilSuccess() async {
    isLoading = true;
    update();

    while (true) {
      try {
        await getAppConfig();
        break;
      } catch (e) {
        print("❌ Inisialisasi gagal, coba ulang: $e");
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    isLoading = false;
    update();
    await handleAppOpen();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> initializeTts() async {
    try {
      await flutterTts.setEngine("com.google.android.tts");
      await flutterTts.awaitSpeakCompletion(true);
      print("✅ TTS Initialized with Google TTS engine");
    } catch (e) {
      print("❌ Error initializing TTS: $e");
      rethrow;
    }
  }

  Future<void> speak(String text) async {
    try {
      print("🔈 Starting TTS...");
      bool isAvailable = await flutterTts.isLanguageAvailable("id-ID").timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print("⏱️ TTS language availability check timed out.");
          return false;
        },
      );

      if (!isAvailable) {
        isAvailable = await flutterTts.isLanguageAvailable("in").timeout(
          const Duration(seconds: 5),
          onTimeout: () => false,
        );
      }

      if (isAvailable) {
        await flutterTts.setLanguage("id-ID");
        await flutterTts.setSpeechRate(0.5);
        await flutterTts.setVolume(1.0);
        await flutterTts.setPitch(1.0);
        await flutterTts.speak(text);
      } else {
        Get.defaultDialog(
          title: 'Peringatan',
          content: const Text(
            'TTS tidak ditemukan, unduh dan install terlebih dahulu lewat menu "Unduh TTS"',
          ),
        );
      }
    } catch (e) {
      print("❌ Error in TTS: $e");
    }
  }

  Future<void> openTTSSettings() async {
    const intent = AndroidIntent(action: 'com.android.settings.TTS_SETTINGS');
    await intent.launch();
  }

  Future<void> downloadTTSEngine() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print("❌ Could not download TTS Engine");
    }
  }

  Future<void> requestCameraPermission() async {
    if (await Permission.camera.isDenied) {
      await Permission.camera.request();
    }
    if (await Permission.microphone.isDenied) {
      await Permission.microphone.request();
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> getAndroidId() async {
    try {
      deviceId = await androidIdPlugin.getId();
      if (deviceId == null || deviceId!.isEmpty) {
        throw Exception("Device ID tidak ditemukan");
      }
    } catch (e) {
      print("❌ Gagal mendapatkan Android ID: $e");
      rethrow;
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

  Future<void> getAppConfig() async {
    try {
      configModel = await services.getAppConfig();
      if (configModel.isNotEmpty()) {
        await requestCameraPermission();
        await initializeTts();
        await getAndroidId();
        webUrl = "${configModel.result?.url}$deviceId";
        WidgetsBinding.instance.addObserver(this);
      }
    } catch (e) {
      print("❌ getAppConfig failed: $e");
      rethrow;
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



import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppConfig {
  static AppsflyerSdk appsflyerSdk;
  static FirebaseMessaging firebaseMessage;
  static StatusData statusData = StatusData();

  // for iOS
  static Future initIOSUninstallMeasurement() async {
    const platform = const MethodChannel('com.fascode.attributable/push');
    try {
      bool success = await platform.invokeMethod('measureUninstall');
      print("measureUninstall: $success");
    } on Exception catch(exception) {
      print(exception.toString());
    }
  }

  static Future initFirebase() async {
    statusData.firebaseStatus = "Firebase initializating...\n";
    try {
      firebaseMessage = FirebaseMessaging();
      firebaseMessage.configure(
        onMessage: onFirebaseMessage,
        onBackgroundMessage: onFirebaseBackgroundMessage,
        onLaunch: onFirebaseLaunch,
        onResume: onFirebaseResume,
      );
      firebaseMessage.onTokenRefresh.listen((deviceToken) {
        statusData.firebaseStatus += "Firebase token refreshed!";
        appsflyerSdk?.updateServerUninstallToken(deviceToken);
      });
    } catch (exception) {
      print("exception : $exception");
      statusData.firebaseStatus += "Firebase init failed\n$exception";
    }
  }
  static Future initAppsFlyerSdk() async {
    statusData.appsFlyerStatus = "Waiting for initialization...\n";
    appsflyerSdk = AppsflyerSdk({
      "afDevKey": "SC6zv6Zb6N52vePBePs5Xo",
      "afAppId": "1510597638",
      "isDebug": true,
    });
    try {
      statusData.appsFlyerStatus = "Initializing...\n";
      await appsflyerSdk.initSdk(
          registerConversionDataCallback: true,
          registerOnAppOpenAttributionCallback: true);
      statusData.appsFlyerStatus += "Attributing...\nWaiting for Attribution data...\n";
      appsflyerSdk.conversionDataStream.asBroadcastStream().listen((data) {
        String statusText = "Attribution data Received\n";
        data.forEach((key, value) => { statusText += "  $key : $value\n"});
        statusData.appsFlyerStatus += statusText;
      });
    } catch (exception) {
      statusData.appsFlyerStatus = "exception : $exception";
    }
  }

  static Future<dynamic> onFirebaseMessage(Map<String, dynamic> message) async {
    print("onFirebaseMessage");
    AppConfig.statusData.firebaseStatus += "Received message in application\n";
    message.forEach((key, value) {
      print("key: $key, value: $value");
      AppConfig.statusData.firebaseStatus += "  $key: $value\n";
    });
  }

  static Future<dynamic> onFirebaseResume(Map<String, dynamic> message) async {
    print("onFirebaseResume");
    message.forEach((key, value) {
      print("key: $key, value: $value");

    });
  }

  static Future<dynamic> onFirebaseLaunch(Map<String, dynamic> message) async {
    print("onFirebaseLaunch");
    message.forEach((key, value) {
      print("key: $key, value: $value");
    });
  }
}
Future<dynamic> onFirebaseBackgroundMessage(Map<String, dynamic> message) async {
  print("onFirebaseBackgroundMessage");
  AppConfig.statusData.firebaseStatus += "Received message in background\n";
  message.forEach((key, value) {
    print("key: $key, value: $value");
    AppConfig.statusData.firebaseStatus += "  $key: $value\n";
  });
}

class ConversionResponse {
  final String status;
  final String type;
  final Map<String, dynamic> data;

  ConversionResponse(this.status, this.type, this.data);

  ConversionResponse.fromJson(Map<dynamic, dynamic> json)
      : this.status = json["status"],
        this.type = json["type"],
        this.data = json["data"];
}
class StatusData with ChangeNotifier {
  static StatusData _instance;
  factory StatusData() => _instance ??= StatusData._();
  StatusData._(){
    print("[Status] New $hashCode");
  }
  String _appsFlyerStatus = "Initializing...";
  String get appsFlyerStatus => _appsFlyerStatus;
  set appsFlyerStatus(String status) {
    _appsFlyerStatus = status;
    notifyListeners();
  }

  String _firebaseStatus = "none";
  String get firebaseStatus => _firebaseStatus;
  set firebaseStatus(String status) {
    _firebaseStatus = status;
    notifyListeners();
  }
}
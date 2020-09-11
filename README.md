# AppsFlyer Uninstall Measurement(Flutter)

A flutter sample app for AppsFlyer Uninstall Measurement implementation.

- For Android, Uninstall Measurement is via Firebase Messaging.
- For iOS, Uninstall Measurement is via APNs directly.

### Steps for Android
#### 1. Add Firebase Messaging plugin.
- ###### 1-1. Refer to https://pub.dev/packages/firebase_messaging
  - Only Android part is required for this guide
- ###### 1-2. If you see an error in `registerWith(PluginRegistry registry)` from , change it as below.
```java
    @Override
    public void registerWith(PluginRegistry registry) {
        // GeneratedPluginRegistrant.registerWith(registry);
        FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
    }
```
#### 2. Initialize Firebase Messaging Plugin
- ###### 2-1. Create a function to instantiate and configure `FirebaseMessaging`
```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class AppConfig {
  static FirebaseMessaging firebaseMessage;
  static Future initFirebase() async {
    firebaseMessage = FirebaseMessaging();
    firebaseMessage.configure(
      onMessage: onFirebaseMessage,
      onBackgroundMessage: onFirebaseBackgroundMessage,
      onLaunch: onFirebaseLaunch,
      onResume: onFirebaseResume,
    );
    firebaseMessage.onTokenRefresh.listen((deviceToken) {
      appsflyerSdk?.updateServerUninstallToken(deviceToken);
    });
  }
  static Future<dynamic> onFirebaseMessage(Map<String, dynamic> message) async {}
  static Future<dynamic> onFirebaseResume(Map<String, dynamic> message) async {}
  static Future<dynamic> onFirebaseLaunch(Map<String, dynamic> message) async {}
}

Future<dynamic> onFirebaseBackgroundMessage(Map<String, dynamic> message) async {}

```

- ###### 2-2. Call it when app is started.
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initFirebase();
  runApp(MyApp());
}

```

#### 3. Add AppsFlyer SDK plugin (Refer to https://pub.dev/packages/appsflyer_sdk/install)
- ###### 3-1 Depend on it
  Add this to your package's pubspec.yaml file:
    ```yaml
    dependencies:
        appsflyer_sdk: ^6.0.2+1
    ```


- ###### 3-2 Install it
    `$ flutter pub get`
- ###### 3-3 Initialize it in Flutter app.
    - Create Init function
        ```dart
        import 'package:appsflyer_sdk/appsflyer_sdk.dart';

        class AppConfig {          
          static AppsflyerSdk appsflyerSdk;
          static Future initAppsFlyerSdk() async {
            appsflyerSdk = AppsflyerSdk({
            "afDevKey": "<YOUR DEV KEY>",
            "afAppId": "<iOS APP ID>",
            "isDebug": true, // Set it to false for release build
          });
        }
        ```
    - Call Init function
        ```dart
        void main() {
            WidgetsFlutterBinding.ensureInitialized();
            AppConfig.initAppsFlyerSdk();
            AppConfig.initFirebase();
            runApp(MyApp());
        }
        ```
#### 4. Listen to Firebase Token and send it to AppsFlyer
  ```dart
  static Future initFirebase() async {
    firebaseMessage = FirebaseMessaging();
    ...
    firebaseMessage.onTokenRefresh.listen((deviceToken) {
      appsflyerSdk?.updateServerUninstallToken(deviceToken);
    });
  }
  ```
###### Done!

### Test and Debug
After implementation and build, you can see the debug logs showing below if the Firebase device token is sent:
```log
D/AppsFlyer_5.4.3(27877): Successfully registered for Uninstall Tracking
```
To make sure Uninstall Measurement is working, listen to the Firebase Message when the app first opened.

- Print logs in `onFirebaseMessage`, which will be called once a Push Notification is received (When app is running foreground)
```dart
  static Future<dynamic> onFirebaseMessage(Map<String, dynamic> message) async {
    print("onFirebaseMessage");
    message.forEach((key, value) {
      print("key: $key, value: $value");
    });
  }
```
- Open the app and check the logs
```log
I/flutter (27877): onFirebaseMessage
I/flutter (27877): key: notification, value: {title: null, body: null}
I/flutter (27877): key: data, value: {af-uinstall-tracking: true}
```

### More details
If you let the app showing notifications for every message received, please exclude AppsFlyer Silent push.
```dart
  static Future<dynamic> onFirebaseMessage(Map<String, dynamic> message) async {
    ...
    if(message.containsKey("af-uinstall-tracking")) {
      // Ignore
    } else {
      // Notify User.
    }
  }
```

And also for Background Message Receiver:
```dart
Future<dynamic> onFirebaseBackgroundMessage(Map<String, dynamic> message) async {
  ...
  if(message.containsKey("af-uinstall-tracking")) {
    // Ignore
  } else {
    // Notify User.
  }
}
```

## Steps for iOS
Editing...
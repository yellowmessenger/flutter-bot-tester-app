import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'storage.dart';

/// Equivalent of the Firebase setup in the iOS tester app's AppDelegate: ask
/// for notification permission, then store the FCM token so profiles with
/// "Push Notification" enabled can pass it to the SDK as the device token.
Future<void> initPush() async {
  try {
    // Reads GoogleService-Info.plist (iOS) / google-services.json (Android).
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (token != null) await Storage.setFcmToken(token);
    messaging.onTokenRefresh.listen(Storage.setFcmToken);
  } catch (e) {
    // Firebase isn't configured or the device can't get a token. The bot
    // still works; only push testing is affected.
    debugPrint('[push] Push notifications not set up (optional): $e');
  }
}

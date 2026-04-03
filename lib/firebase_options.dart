import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase web is not configured for this app yet.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        return android;
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCrF27xDYskePQakfvrb_xc5od-mJg3l7k',
    appId: '1:734747496222:ios:ca28d89f900d723c18830f',
    messagingSenderId: '734747496222',
    projectId: 'devdatapoint-7f575',
    storageBucket: 'devdatapoint-7f575.firebasestorage.app',
    iosBundleId: 'app.rork.k1oi3mhgah0fgszldnbv8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_FIREBASE_API_KEY',
    appId: 'YOUR_ANDROID_FIREBASE_APP_ID',
    messagingSenderId: 'YOUR_FIREBASE_SENDER_ID',
    projectId: 'YOUR_FIREBASE_PROJECT_ID',
  );
}
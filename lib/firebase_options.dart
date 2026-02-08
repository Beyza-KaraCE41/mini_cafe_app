import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ✅ WEB - Gerçek Firebase Credentials
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAHLokMjuyeKapPvUwd82krCs3ezBmZYlg',
    appId: '1:541778859226:web:05c9b606f3e4b82e5181e3',
    messagingSenderId: '541778859226',
    projectId: 'mini-cafe-app',
    authDomain: 'mini-cafe-app.firebaseapp.com',
    databaseURL: 'https://mini-cafe-app.firebaseio.com',
    storageBucket: 'mini-cafe-app.firebasestorage.app',
    measurementId: 'G-DTWSVJV2TY',
  );

  // ANDROID - Gerçek Firebase Credentials
  // Not: Android credentials'ını firebase console'dan google-services.json dosyasından alabilirsin
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAHLokMjuyeKapPvUwd82krCs3ezBmZYlg',
    appId: '1:541778859226:android:05c9b606f3e4b82e5181e3',
    messagingSenderId: '541778859226',
    projectId: 'mini-cafe-app',
    databaseURL: 'https://mini-cafe-app.firebaseio.com',
    storageBucket: 'mini-cafe-app.firebasestorage.app',
  );

  // iOS - Gerçek Firebase Credentials
  // Not: iOS credentials'ını firebase console'dan GoogleService-Info.plist dosyasından alabilirsin
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAHLokMjuyeKapPvUwd82krCs3ezBmZYlg',
    appId: '1:541778859226:ios:05c9b606f3e4b82e5181e3',
    messagingSenderId: '541778859226',
    projectId: 'mini-cafe-app',
    databaseURL: 'https://mini-cafe-app.firebaseio.com',
    storageBucket: 'mini-cafe-app.firebasestorage.app',
  );

  // macOS - Gerçek Firebase Credentials
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAHLokMjuyeKapPvUwd82krCs3ezBmZYlg',
    appId: '1:541778859226:macos:05c9b606f3e4b82e5181e3',
    messagingSenderId: '541778859226',
    projectId: 'mini-cafe-app',
    databaseURL: 'https://mini-cafe-app.firebaseio.com',
    storageBucket: 'mini-cafe-app.firebasestorage.app',
  );
}

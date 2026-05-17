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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can add iOS support by running: flutterfire configure',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJgPKYfSeDdaV-zk6pG3ldZxbq4cQ-SxI',
    appId: '1:121482598276:android:3e169f13e7e80e35b2afd1',
    messagingSenderId: '121482598276',
    projectId: 'displacement-camp',
    storageBucket: 'displacement-camp.firebasestorage.app',
  );

  // Web config — fill in if you add Web support later
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBJgPKYfSeDdaV-zk6pG3ldZxbq4cQ-SxI',
    appId: '1:121482598276:web:XXXXXXXXXXXXXXXX', // ← استبدل بعد إضافة Web app
    messagingSenderId: '121482598276',
    projectId: 'displacement-camp',
    storageBucket: 'displacement-camp.firebasestorage.app',
    authDomain: 'displacement-camp.firebaseapp.com',
  );
}

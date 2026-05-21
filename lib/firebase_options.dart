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

  // إعدادات الأندرويد مأخوذة بدقة من ملف google-services.json الجديد
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0F-ELKoFlWsXQgIrlEtYIhK0Zpbt64MQ',
    appId: '1:201947454334:android:2f0468984e0554aa85f12f',
    messagingSenderId: '201947454334',
    projectId: 'displaced-camps',
    storageBucket: 'displaced-camps.firebasestorage.app',
  );

  // إعدادات الويب المحدثة بناءً على بيانات المشروع الجديد
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD0F-ELKoFlWsXQgIrlEtYIhK0Zpbt64MQ',
    appId:
        '1:201947454334:web:xxxxxxxxxxxxxxxxxxxxxx', // ستحتاج لاستبدال هذا المعرّف إذا أنشأت Web App داخل الفيربيس لاحقاً
    messagingSenderId: '201947454334',
    projectId: 'displaced-camps',
    storageBucket: 'displaced-camps.firebasestorage.app',
    authDomain: 'displaced-camps.firebaseapp.com',
  );
}

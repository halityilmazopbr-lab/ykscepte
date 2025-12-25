// Firebase configuration matching google-services.json
// Project: gen-lang-client-0573740353

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
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android yapılandırması (google-services.json ile eşleşiyor)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWF_39IA3d9CgBl8Om-W0KkPllsL2SQX8',
    appId: '1:726026626971:android:cdde27c861a25b57c6a33e',
    messagingSenderId: '726026626971',
    projectId: 'gen-lang-client-0573740353',
    storageBucket: 'gen-lang-client-0573740353.firebasestorage.app',
  );

  // Web yapılandırması
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAWF_39IA3d9CgBl8Om-W0KkPllsL2SQX8',
    appId: '1:726026626971:web:cdde27c861a25b57c6a33e',
    messagingSenderId: '726026626971',
    projectId: 'gen-lang-client-0573740353',
    storageBucket: 'gen-lang-client-0573740353.firebasestorage.app',
  );

  // iOS yapılandırması
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWF_39IA3d9CgBl8Om-W0KkPllsL2SQX8',
    appId: '1:726026626971:ios:cdde27c861a25b57c6a33e',
    messagingSenderId: '726026626971',
    projectId: 'gen-lang-client-0573740353',
    storageBucket: 'gen-lang-client-0573740353.firebasestorage.app',
    iosBundleId: 'com.ykscepte.app',
  );

  // macOS yapılandırması
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAWF_39IA3d9CgBl8Om-W0KkPllsL2SQX8',
    appId: '1:726026626971:macos:cdde27c861a25b57c6a33e',
    messagingSenderId: '726026626971',
    projectId: 'gen-lang-client-0573740353',
    storageBucket: 'gen-lang-client-0573740353.firebasestorage.app',
    iosBundleId: 'com.ykscepte.app',
  );

  // Windows yapılandırması
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAWF_39IA3d9CgBl8Om-W0KkPllsL2SQX8',
    appId: '1:726026626971:web:cdde27c861a25b57c6a33e',
    messagingSenderId: '726026626971',
    projectId: 'gen-lang-client-0573740353',
    storageBucket: 'gen-lang-client-0573740353.firebasestorage.app',
  );
}

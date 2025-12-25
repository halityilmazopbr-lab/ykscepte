// Firebase configuration matching google-services.json
// Project: neural-guard-473908-j7

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
    apiKey: 'AIzaSyCuK_RiT0B2_XZsDZkOyPLoD7Vz10EfI8k',
    appId: '1:124569660139:android:0ed2d4c19a8a77bcb52cae',
    messagingSenderId: '124569660139',
    projectId: 'neural-guard-473908-j7',
    storageBucket: 'neural-guard-473908-j7.firebasestorage.app',
  );

  // Web yapılandırması
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCuK_RiT0B2_XZsDZkOyPLoD7Vz10EfI8k',
    appId: '1:124569660139:web:0ed2d4c19a8a77bcb52cae',
    messagingSenderId: '124569660139',
    projectId: 'neural-guard-473908-j7',
    storageBucket: 'neural-guard-473908-j7.firebasestorage.app',
  );

  // iOS yapılandırması
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCuK_RiT0B2_XZsDZkOyPLoD7Vz10EfI8k',
    appId: '1:124569660139:ios:0ed2d4c19a8a77bcb52cae',
    messagingSenderId: '124569660139',
    projectId: 'neural-guard-473908-j7',
    storageBucket: 'neural-guard-473908-j7.firebasestorage.app',
    iosBundleId: 'com.example.yks_cepte',
  );

  // macOS yapılandırması
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCuK_RiT0B2_XZsDZkOyPLoD7Vz10EfI8k',
    appId: '1:124569660139:macos:0ed2d4c19a8a77bcb52cae',
    messagingSenderId: '124569660139',
    projectId: 'neural-guard-473908-j7',
    storageBucket: 'neural-guard-473908-j7.firebasestorage.app',
    iosBundleId: 'com.example.yks_cepte',
  );

  // Windows yapılandırması
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCuK_RiT0B2_XZsDZkOyPLoD7Vz10EfI8k',
    appId: '1:124569660139:web:0ed2d4c19a8a77bcb52cae',
    messagingSenderId: '124569660139',
    projectId: 'neural-guard-473908-j7',
    storageBucket: 'neural-guard-473908-j7.firebasestorage.app',
  );
}

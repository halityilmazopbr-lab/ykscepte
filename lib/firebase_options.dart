// File generated based on Firebase CLI configuration
// Project: gen-lang-client-0573740353 (YKS MASTER)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase yapılandırma dosyası
/// 
/// Project ID: gen-lang-client-0573740353
/// Project Name: YKS MASTER
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

  // Web yapılandırması
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBP2HHKZL7pNug9pzHRzIhrejJL0H2uMkw',
    appId: '1:726026626971:web:c81534aaf28a3858c6a33e',
    messagingSenderId: '726026626971',
    projectId: 'gen-lang-client-0573740353',
    authDomain: 'gen-lang-client-0573740353.firebaseapp.com',
    storageBucket: 'gen-lang-client-0573740353.firebasestorage.app',
  );

  // Android yapılandırması
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBP2HHKZL7pNug9pzHRzIhrejJL0H2uMkw',
    appId: '1:726026626971:web:c81534aaf28a3858c6a33e', // Web appId kullanılıyor
    messagingSenderId: '726026626971',
    projectId: 'gen-lang-client-0573740353',
    storageBucket: 'gen-lang-client-0573740353.firebasestorage.app',
  );

  // iOS yapılandırması
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBP2HHKZL7pNug9pzHRzIhrejJL0H2uMkw',
    appId: '1:726026626971:web:c81534aaf28a3858c6a33e', // Web appId kullanılıyor
    messagingSenderId: '726026626971',
    projectId: 'gen-lang-client-0573740353',
    storageBucket: 'gen-lang-client-0573740353.firebasestorage.app',
    iosBundleId: 'com.ykscepte.app',
  );

  // macOS yapılandırması
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBP2HHKZL7pNug9pzHRzIhrejJL0H2uMkw',
    appId: '1:726026626971:web:c81534aaf28a3858c6a33e',
    messagingSenderId: '726026626971',
    projectId: 'gen-lang-client-0573740353',
    storageBucket: 'gen-lang-client-0573740353.firebasestorage.app',
    iosBundleId: 'com.ykscepte.app',
  );

  // Windows yapılandırması (Web config kullanıyor)
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBP2HHKZL7pNug9pzHRzIhrejJL0H2uMkw',
    appId: '1:726026626971:web:c81534aaf28a3858c6a33e',
    messagingSenderId: '726026626971',
    projectId: 'gen-lang-client-0573740353',
    authDomain: 'gen-lang-client-0573740353.firebaseapp.com',
    storageBucket: 'gen-lang-client-0573740353.firebasestorage.app',
  );
}

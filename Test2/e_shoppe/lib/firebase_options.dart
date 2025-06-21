// Generated Firebase configuration.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  // Web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBflGsVJ2IP9RulYVhew344a9FKX7HSIHo',
    appId: '1:387402163402:web:5fd70b399dc4e34c204033',
    messagingSenderId: '387402163402',
    projectId: 'eshoppe-ee802',
    authDomain: 'eshoppe-ee802.firebaseapp.com',
    storageBucket: 'eshoppe-ee802.appspot.com',
    measurementId: 'G-V7KQZCXKS8',
  );

  // TEMP: reuse web config for other platforms until their real configs are generated.
  static const FirebaseOptions android = web;
  static const FirebaseOptions ios = web;
  static const FirebaseOptions macos = web;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return web;
    }
  }
}

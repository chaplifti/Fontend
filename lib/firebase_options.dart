// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCXMKX3wKUykx1x4EaMA3X7vBLiSE0quDw',
    appId: '1:895226357293:web:2a799c2658ead410bcbaa4',
    messagingSenderId: '895226357293',
    projectId: 'chaplifti-65288',
    authDomain: 'chaplifti-65288.firebaseapp.com',
    databaseURL: 'https://chaplifti-65288-default-rtdb.firebaseio.com',
    storageBucket: 'chaplifti-65288.appspot.com',
    measurementId: 'G-YYTWGQM9B8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAdhGb0MRKoyZb8GX4CmcuAvf34-v2oCxk',
    appId: '1:895226357293:android:fd58e1d76f472f06bcbaa4',
    messagingSenderId: '895226357293',
    projectId: 'chaplifti-65288',
    databaseURL: 'https://chaplifti-65288-default-rtdb.firebaseio.com',
    storageBucket: 'chaplifti-65288.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIfLdDEdDiOnAa5DxA215R6jAJg8wEFW4',
    appId: '1:895226357293:ios:ba9a76eb1bc9e642bcbaa4',
    messagingSenderId: '895226357293',
    projectId: 'chaplifti-65288',
    databaseURL: 'https://chaplifti-65288-default-rtdb.firebaseio.com',
    storageBucket: 'chaplifti-65288.appspot.com',
    iosBundleId: 'com.chaplifti.chaplifti',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCIfLdDEdDiOnAa5DxA215R6jAJg8wEFW4',
    appId: '1:895226357293:ios:f3d7230ad41587f7bcbaa4',
    messagingSenderId: '895226357293',
    projectId: 'chaplifti-65288',
    databaseURL: 'https://chaplifti-65288-default-rtdb.firebaseio.com',
    storageBucket: 'chaplifti-65288.appspot.com',
    iosBundleId: 'com.example.rcFlGopoolar.RunnerTests',
  );
}

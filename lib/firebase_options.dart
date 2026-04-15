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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCYUFugtK4-u_0UMLHaL7pEcOTZrgaG8c0',
    appId: '1:316104868795:web:e777b4f5ce2bea145f3a9e',
    messagingSenderId: '316104868795',
    projectId: 'hustleamclothingco',
    authDomain: 'hustleamclothingco.firebaseapp.com',
    storageBucket: 'hustleamclothingco.firebasestorage.app',
    measurementId: 'G-W820QMNRR7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD7dmVrOT5G0CUNeni_1kfg2O5UGbMnxJc',
    appId: '1:316104868795:android:09ba42a0d48275015f3a9e',
    messagingSenderId: '316104868795',
    projectId: 'hustleamclothingco',
    storageBucket: 'hustleamclothingco.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCEyQIja0JJxmC2HYQDNbsRwyxKY_JV4UY',
    appId: '1:316104868795:ios:2445fb078eb3636a5f3a9e',
    messagingSenderId: '316104868795',
    projectId: 'hustleamclothingco',
    storageBucket: 'hustleamclothingco.firebasestorage.app',
    iosBundleId: 'com.example.groupProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCEyQIja0JJxmC2HYQDNbsRwyxKY_JV4UY',
    appId: '1:316104868795:ios:2445fb078eb3636a5f3a9e',
    messagingSenderId: '316104868795',
    projectId: 'hustleamclothingco',
    storageBucket: 'hustleamclothingco.firebasestorage.app',
    iosBundleId: 'com.example.groupProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCYUFugtK4-u_0UMLHaL7pEcOTZrgaG8c0',
    appId: '1:316104868795:web:4d1f078dafaae0c25f3a9e',
    messagingSenderId: '316104868795',
    projectId: 'hustleamclothingco',
    authDomain: 'hustleamclothingco.firebaseapp.com',
    storageBucket: 'hustleamclothingco.firebasestorage.app',
    measurementId: 'G-DZQXP6NQDC',
  );
}

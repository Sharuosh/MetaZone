import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';

import 'app/metazone_app.dart';

import 'core/dependency_injection/service_locator.dart';
import 'core/localization/localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Development/testing configuration.
    //
    // App Check must be activated after Firebase.initializeApp()
    // and before MetaZone starts using Firebase-backed services.
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
  } catch (_) {}

  await LocalizationRegistration.register(locator);

  runApp(const MetaZoneApp());
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

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
  } catch (_) {}

  await LocalizationRegistration.register(locator);

  runApp(const MetaZoneApp());
}
// File: lib/main.dart
// MetaZone — Main Entry (Clean • Stable • Native Deep Link Ready)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Localization
import 'core/localization/localization_setup.dart';
import 'core/theme/theme.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'screens/main_navigation.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/home/splash/splash_screen.dart';
import 'screens/home/profile/public_profile_screen.dart';

// 🔑 Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Init Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  // Init Localization
  await LocalizationSetup.init();

  runApp(const MetaZoneApp());
}


class MetaZoneApp extends StatefulWidget {
  const MetaZoneApp({super.key});

  @override
  State<MetaZoneApp> createState() => _MetaZoneAppState();
}

class _MetaZoneAppState extends State<MetaZoneApp>
    with WidgetsBindingObserver {

  void _onThemeChanged(String themeKey) {
    setState(() => AppColors.setTheme(themeKey));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 🟢 handle deep link on app start
    _handleUri(Uri.base);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 🟡 Handle app resume (when opened from link while running)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final uri = Uri.base;
      _handleUri(uri);
    }
  }

  /// ===============================
  /// Native Deep Link Resolver
  /// Supports:
  /// https://meta.zone/u/username
  /// ===============================
  void _handleUri(Uri uri) {
    if (uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == 'u') {

      final username = uri.pathSegments[1];

      // delay navigation until UI is ready
      Future.microtask(() {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => PublicProfileScreen(username: username),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      primaryColor: AppColors.primary,
    );

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: "MetaZone",

      locale: LocalizationSetup.currentLocale,
      supportedLocales: LocalizationSetup.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      theme: theme,

      /// البداية → Splash → AuthWrapper
      home: const SplashScreen(),

      routes: {
        "/auth": (context) => const SplashScreen(),
        "/login": (context) => const LoginScreen(),
        "/signup": (context) => const SignUpScreen(),
        "/forgot": (context) => const ForgotPasswordScreen(),
        "/reset": (context) => ResetPasswordScreen(oobCode: ""),
        "/otp": (context) {
          final userId =
          ModalRoute.of(context)!.settings.arguments as String;
          return OTPScreen(userId: userId);
        },
        "/home": (context) => MainNavigation(
          onThemeChanged: _onThemeChanged,
        ),
      },
    );
  }
}

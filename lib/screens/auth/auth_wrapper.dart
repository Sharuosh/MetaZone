import 'package:flutter/material.dart';
import '/services/auth_gate_service.dart';
import '../main_navigation.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthGateService _authGate = AuthGateService();
  late final Future _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _authGate.signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Auth Error")),
          );
        }

        return MainNavigation(
          onThemeChanged: (_) {},
        );
      },
    );
  }
}

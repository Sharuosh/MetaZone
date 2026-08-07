import 'package:flutter/material.dart';

final class MetaZoneApp extends StatelessWidget {
  const MetaZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MetaZone',

      theme: ThemeData.light(
        useMaterial3: true,
      ),

      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),

      themeMode: ThemeMode.system,

      home: const Scaffold(
        body: Center(
          child: Text('MetaZone'),
        ),
      ),
    );
  }
}
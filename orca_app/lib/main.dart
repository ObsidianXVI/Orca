library orca_app;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:orca_core/orca.dart';

part './daemon_bridge.dart';
part './views/apps_view.dart';
part './views/dashboard_view.dart';
part './support/daemon_bridge_access.dart';

void main() async {
  runApp(const OrcaApp());
}

class OrcaApp extends StatefulWidget {
  const OrcaApp({super.key});

  @override
  State<StatefulWidget> createState() => OrcaAppState();
}

class OrcaAppState extends State<OrcaApp> {
  AppComponent? currentAppComponent;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          primary: const Color(0xff4A4E69),
          onPrimary: const Color(0xff9A8C98),
          secondary: const Color(0xff9A8C98),
          onSecondary: const Color(0xff9a8c98),
          background: const Color(0xff4A4E69),
          onBackground: const Color(0xff9A8C98),
          surface: const Color(0xff22223B),
          onSurface: const Color(0xffF2E9E4),
          error: const Color(0xffd62828).withOpacity(0.2),
          onError: const Color(0xffd62828),
          brightness: Brightness.dark,
        ),
      ),
      routes: {
        '/': (context) => const DashboardView(),
        '/apps': (_) => const AppsView(),
      },
    );
  }
}

library orca_app;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:orca_core/orca.dart';

part './ui/color_scheme.dart';
part './ui/button_style.dart';
part './ui/text_theme.dart';
part './ui/runtime_window.dart';

part './views/apps_view.dart';
part './views/engines_view.dart';
part './views/services_view.dart';
part './views/dashboard_view.dart';
part './views/runtimes_view.dart';

part './forms/runtime_create.dart';

part './orca_api_client.g.dart';

void main() async {
  runApp(const OrcaApp());
}

class OrcaApp extends StatefulWidget {
  const OrcaApp({super.key});

  @override
  State<StatefulWidget> createState() => OrcaAppState();
}

class OrcaAppState extends State<OrcaApp> {
  OrcaSpec? currentAppComponent;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: OrcaColorSchme.colorSchemeDark,
          textButtonTheme: OrcaButtonStyle.textButtonStyle,
          cardTheme: CardTheme(surfaceTintColor: OrcaColorSchme.lightPurple)),
      routes: {
        '/': (context) => const DashboardView(),
        '/apps': (_) => const AppsView(),
        '/engines': (_) => const EnginesView(),
        '/services': (_) => const ServicesView(),
        '/runtimes': (_) => const RuntimesView(),
      },
    );
  }
}

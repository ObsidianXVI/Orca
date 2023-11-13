library orca_app;

import 'package:flutter/material.dart';
import 'package:orca_core/orca.dart';

part './daemon_bridge.dart';
part './views/apps_view.dart';

void main() {
  runApp(const OrcaApp());
}

class OrcaApp extends StatefulWidget {
  const OrcaApp({super.key});

  @override
  State<StatefulWidget> createState() => OrcaAppState();
}

class OrcaAppState extends State<OrcaApp> {
  AppComponent? currentAppComponent = appComponents.firstOrNull;

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
        '/': (context) => Scaffold(
              appBar: AppBar(
                title: DropdownMenu<AppComponent>(
                  initialSelection: appComponents.firstOrNull,
                  onSelected: (value) =>
                      setState(() => currentAppComponent = value),
                  dropdownMenuEntries:
                      List<DropdownMenuEntry<AppComponent>>.generate(
                    appComponents.length,
                    (i) => DropdownMenuEntry<AppComponent>(
                      value: appComponents[i],
                      label: appComponents[i].appName,
                    ),
                  ),
                ),
              ),
              drawer: Drawer(
                child: ListView(
                  children: [
                    const DrawerHeader(
                      child: Text('Orca'),
                    ),
                    ListTile(
                      title: const Text('Apps'),
                      onTap: () {
                        Navigator.of(context).pushNamed('/apps');
                      },
                    ),
                    ListTile(
                      title: const Text('Engines'),
                      onTap: () {},
                    ),
                    ListTile(
                      title: const Text('Runtimes'),
                      onTap: () {},
                    ),
                    ListTile(
                      title: const Text('Environments'),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
        '/apps': (_) => const AppsView(),
      },
    );
  }
}

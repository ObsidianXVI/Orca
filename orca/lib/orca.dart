library orca;

import 'dart:io';
import 'package:collection/collection.dart';

part './orca_configs.dart';

typedef JSON = Map<String, dynamic>;

class OrcaInteractive {}

class OrcaServer {
  static late OrcaConfigs orcaConfigs;
  static final Map<String, Process> processes = {};

  static Future<void> init(OrcaConfigs configs) async {
    orcaConfigs = configs;
  }

  static void serveApp(String appName) async {
    final OrcaAppConfig? appConfig = orcaConfigs.apps.firstWhereOrNull(
        (OrcaAppConfig appConfig) => appConfig.appName == appName);
    if (appConfig != null) {
      processes.addAll({
        appName: await Process.start(
          orcaConfigs.flutterPath,
          ['run', '--release', '-d', 'chrome'],
          workingDirectory: appConfig.path,
        ),
      });
      print('Serving "$appName"...');
    }
  }

  static void stopServingApp(String appName) async {
    final Process? process = processes[appName];
    if (process != null) {
      process.kill();
      print('Stopped serving "$appName"...');
    } else {
      print('No app named "$appName" is running');
    }
  }
}

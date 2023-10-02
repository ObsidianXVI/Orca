library orca;

import 'dart:convert';
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

  static void serveApp(
    String appName, {
    required Stream<List<int>> stdinStream,
    bool pipeIO = false,
  }) async {
    final OrcaAppConfig? appConfig = orcaConfigs.apps.firstWhereOrNull(
        (OrcaAppConfig appConfig) => appConfig.appName == appName);
    if (appConfig != null) {
      print('Serving "$appName"...');
      final Process proc = await Process.start(
        orcaConfigs.flutterPath,
        ['run', '--release', '-d', 'chrome'],
        workingDirectory: appConfig.path,
      );
      if (pipeIO) {
        print("Piping stdin and stderr from process");
        proc
          ..stdout.pipe(stdout)
          ..stderr.pipe(stderr);
        stdin.transform(utf8.decoder).transform(LineSplitter());
        stdinStream.listen((e) {
          proc.stdin.write(e);
        });
      }
      processes.addAll({appName: proc});
      print('Done');
    } else {
      print('No OrcaAppConfig found for "$appName"');
    }
  }

  static void stopServingApp(String appName) async {
    _withProcess(
      appName: appName,
      exitMsg: 'No app named "$appName" is running',
      action: (Process p) {
        p.stdin.close();
        p.kill();
        print('Stopped serving "$appName"...');
      },
    );
  }

  static void getLogsFor(String appName) {
    _withProcess(
      appName: appName,
      exitMsg: 'No app named "$appName" is running',
      action: (Process p) {
        p.stdout.transform(utf8.decoder).forEach((String line) {
          stdout.writeln(line);
        });
      },
    );
  }

  static void activateLiveMode(String appName) {
    _withProcess(
      appName: appName,
      exitMsg: 'No app named "$appName" is running',
      action: (Process p) {
        p.stdout.pipe(stdout);
        p.stdout;
      },
    );
  }

  static void _withProcess({
    required String appName,
    required String exitMsg,
    required Function(Process) action,
  }) {
    final Process? process = processes[appName];
    if (process != null) {
      action(process);
    } else {
      print(exitMsg);
    }
  }
}

library orca;

import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';

part './orca_configs.dart';

typedef JSON = Map<String, dynamic>;

/// An interactive session where every command is sent directly to a shell instance
/// whose working directory is at the project's root
class OrcaInteractive {}

class OrcaCore {
  static late OrcaConfigs orcaConfigs;
  static final Map<String, Process> processes = {};
  static late final HttpServer server;

  static Future<void> init(OrcaConfigs configs) async {
    orcaConfigs = configs;
    server = await HttpServer.bind(InternetAddress.anyIPv4, 8082);
    print(
        "Server listening on ${Uri(scheme: 'http', host: server.address.host, port: server.port)}");
    server.listen((HttpRequest req) {
      if (req.uri.pathSegments.isNotEmpty) {
        switch (req.uri.pathSegments.first) {
          case 'apps':
            req.response
              ..statusCode = 200
              ..headers.set('Access-Control-Allow-Origin', '*')
              ..write(
                jsonEncode({
                  'payload': [for (final a in orcaConfigs.apps) a.toJson()]
                }),
              );
            break;
        }
      } else {
        req.response
          ..headers.set('Access-Control-Allow-Origin', '*')
          ..statusCode = 200;
      }
      req.response.close();
    });
  }

  static Future<OrcaAppConfig> getAppConfig(String appPath) async =>
      OrcaAppConfig.fromJson(
        jsonDecode(
          await File(appPath).readAsString(),
        ),
      );

  static void serveApp(
    String appName, {
    required Stream<List<int>> stdinStream,
    bool pipeIO = false,
  }) async {
    final AppComponent? appComponent = orcaConfigs.apps
        .firstWhereOrNull((AppComponent comp) => comp.appName == appName);
    if (appComponent != null) {
      final OrcaAppConfig appConfig = await getAppConfig(appComponent.path);
      if (appConfig.commands.isNotEmpty) {
        print("The app would like to run the following commands:\n");
        for (String cmd in appConfig.commands) {
          print("    $cmd");
        }
        print("\nType 'exit' and hit enter to abort\n");
        await Future.delayed(
          const Duration(seconds: 3),
          () async {
            print('Initialising "$appName"...\n==========');
            for (String cmd in appConfig.commands) {
              final List<String> cmdParts = cmd.split(' ');
              await Process.run(
                cmdParts.first,
                cmdParts.sublist(1),
                workingDirectory: appComponent.path,
              )
                ..stdout.pipe(stdout)
                ..stderr.pipe(stderr);
            }
            print("==========");
            print('Serving "$appName"...');
            final Process proc = await Process.start(
              orcaConfigs.flutterPath,
              ['run', '--release', '-d', 'chrome'],
              workingDirectory: appComponent.path,
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
          },
        );
      }
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

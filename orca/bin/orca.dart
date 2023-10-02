import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:orca/orca.dart' as orca;
import 'package:args/args.dart';
import 'package:args/command_runner.dart';

final Map<String, dynamic> configsJson = {
  "flutterPath": "/usr/local/bin/flutter/bin/flutter",
  "apps": [
    {
      "appName": "testproj",
      "version": "1.0.0",
      "path":
          "/Users/OBSiDIAN/Downloads/Shelves/VSCode/Repositories/Playground/tproj/testproj"
    }
  ]
};

void main(List<String> _) {
  stdin.listen((e) => OrcaCLI.stdinController.add(e));
  OrcaCLI.stdinBroadcast
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((String line) {
    if (line.trim() == 'exit') exit(0);
    if (!OrcaCLI.interactiveMode) OrcaCLI.commandRunner.run(line.split(' '));
  });
}

class OrcaCLI {
  static bool interactiveMode = false;
  static final StreamController<List<int>> stdinController =
      StreamController.broadcast();
  static Stream<List<int>> get stdinBroadcast => stdinController.stream;

  static final CommandRunner commandRunner = CommandRunner('orca',
      'Orchestrate the deployment, installation, maintenance and runtimes of locally-hosted Flutter web apps.')
    ..addCommand(OrcaServeCommand())
    ..addCommand(OrcaStopCommand())
    ..addCommand(OrcaDumpCommand());
}

class OrcaServeCommand extends Command {
  @override
  final name = 'serve';
  @override
  final description = 'Start serving a specific app.';

  OrcaServeCommand() {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Exact name of the app to serve, as defined in its pubspec file.',
        valueHelp: 'name_of_app',
      )
      ..addFlag(
        'interactive',
        abbr: 'i',
        help:
            'Launch in interactive mode, connecting I/O streams to the process.',
        defaultsTo: false,
        negatable: false,
      );
  }

  @override
  FutureOr? run() async {
    await orca.OrcaServer.init(orca.OrcaConfigs.fromJson(configsJson));
    if (argResults!['name'] != null) {
      OrcaCLI.interactiveMode = argResults!['interactive'];
      orca.OrcaServer.serveApp(
        argResults!['name'],
        pipeIO: argResults!['interactive'],
        stdinStream: OrcaCLI.stdinBroadcast,
      );
    } else {
      print("No name specified");
    }
  }
}

class OrcaStopCommand extends Command {
  @override
  final name = 'stop';
  @override
  final description = 'Stop serving a specific app.';

  OrcaStopCommand() {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Exact name of the app to stop, as defined in its pubspec file.',
      valueHelp: 'name_of_app',
    );
  }

  @override
  FutureOr? run() {
    if (argResults!['name'] != null) {
      orca.OrcaServer.stopServingApp(argResults!['name']);
    } else {
      print("No name specified");
    }
  }
}

class OrcaDumpCommand extends Command {
  @override
  final name = 'dump';
  @override
  final description = 'Dump console logs for a specific app.';

  OrcaDumpCommand() {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Exact name of the app to stop, as defined in its pubspec file.',
      valueHelp: 'name_of_app',
    );
  }

  @override
  FutureOr? run() {
    if (argResults!['name'] != null) {
      orca.OrcaServer.getLogsFor(argResults!['name']);
    } else {
      print("No name specified");
    }
  }
}

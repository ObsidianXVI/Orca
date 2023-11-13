import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:orca_core/orca.dart';

late final String orcaPath;
late final OrcaConfigs configs;
void main(List<String> _) async {
  final env = Platform.environment;
  if (env.containsKey('ORCA_PATH')) {
    orcaPath = env['ORCA_PATH'] as String;
  } else {
    print("Could not detect env variable for ORCA_PATH");
    exit(1);
  }
  configs = OrcaConfigs.fromJson(
    jsonDecode(
      await File("$orcaPath/configs/orca_configs.json").readAsString(),
    ),
  );
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
    ..addCommand(ServeCommand())
    ..addCommand(StopCommand())
    ..addCommand(DumpCommand())
    ..addCommand(InstallCommand());
}

class ServeCommand extends Command {
  @override
  final name = 'serve';
  @override
  final description = 'Start serving a specific app.';

  ServeCommand() {
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
  FutureOr? run() {
    OrcaCore.init(configs);
    if (argResults!['name'] != null) {
      OrcaCLI.interactiveMode = argResults!['interactive'];
      OrcaCore.serveApp(
        argResults!['name'],
        pipeIO: argResults!['interactive'],
        stdinStream: OrcaCLI.stdinBroadcast,
      );
    } else {
      print("No name specified");
    }
  }
}

class StopCommand extends Command {
  @override
  final name = 'stop';
  @override
  final description = 'Stop serving a specific app.';

  StopCommand() {
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
      OrcaCore.stopServingApp(argResults!['name']);
    } else {
      print("No name specified");
    }
  }
}

class DumpCommand extends Command {
  @override
  final name = 'dump';
  @override
  final description = 'Dump console logs for a specific app.';

  DumpCommand() {
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
      OrcaCore.getLogsFor(argResults!['name']);
    } else {
      print("No name specified");
    }
  }
}

class InstallCommand extends Command {
  @override
  final name = 'install';
  @override
  final description = 'Install an Orca-enabled app from path.';

  InstallCommand() {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Exact name of the app, as defined in its pubspec file.',
        mandatory: true,
        valueHelp: 'name_of_app',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help:
            "Path to the directory that the app's pubspec file is located in.",
        mandatory: true,
        valueHelp: 'path/to/directory',
      );
  }

  @override
  FutureOr? run() {}
}

import 'dart:async';
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

void main(List<String> arguments) {
  OrcaCLI.commandRunner.run(arguments);
}

class OrcaCLI {
  static final CommandRunner commandRunner = CommandRunner('orca',
      'Orchestrate the deployment, installation, maintenance and runtimes of locally-hosted Flutter web apps.')
    ..addCommand(
      OrcaServeCommand(),
    )
    ..addCommand(
      OrcaStopCommand(),
    );
}

class OrcaServeCommand extends Command {
  @override
  final name = 'serve';
  @override
  final description = 'Start serving a specific app.';

  OrcaServeCommand() {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Exact name of the app to serve, as defined in its pubspec file.',
      valueHelp: 'name_of_app',
    );
  }

  @override
  FutureOr? run() async {
    orca.OrcaServer.init(orca.OrcaConfigs.fromJson(configsJson));
    if (argResults!.wasParsed('name')) {
      orca.OrcaServer.serveApp(argResults!.options.first);
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
    if (argResults!.wasParsed('name')) {
      orca.OrcaServer.stopServingApp(argResults!.options.first);
    } else {
      print("No name specified");
    }
  }
}

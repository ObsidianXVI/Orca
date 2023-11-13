import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
      await File("$orcaPath/orca_configs.json").readAsString(),
    ),
  );
  print("Launching daemon...");
  await OrcaCore.init(configs);
  print("Daemon launched successfully!\n===");
}

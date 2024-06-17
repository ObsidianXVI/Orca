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
  final String configsPath = "$orcaPath/orca_configs.json";
  configs = OrcaConfigs.fromJson(
    jsonDecode(await File(configsPath).readAsString()),
    configsPath: configsPath,
  );
  print("Launching daemon...");
  await OrcaCore.init(
    configs,
  );
  print("Daemon launched successfully!\n===");
}

part of orca_core;

class OrcaRuntime {
  final OrcaConfigs configs;
  final String appName;
  final String engineVersion;
  final List<String> serviceNames;
  // late final Uri address;
  final List<String> logs = [];

  OrcaRuntime({
    required this.configs,
    required this.appName,
    required this.engineVersion,
    required this.serviceNames,
  });

  OrcaRuntime.fromJson(JSON data)
      : appName = data['appName'],
        engineVersion = data['engineVersion'],
        serviceNames = (data['serviceNames'] as List).cast<String>(),
        configs = OrcaConfigs.fromJson(
          data['configs'],
          configsPath: data['configs']['configsPath'],
        ) {
    if (data.containsKey('logs')) {
      logs.addAll((data['logs'] as List).cast<String>());
    }
  }

  Future<Process?> spawn() async {
    final AppComponent? aComp =
        configs.apps.firstWhereOrNull((a) => a.appName == appName);
    if (aComp == null) {
      logs.add("🐋 Could not find app with specified name '$appName'");
      return null;
    }
    final EngineComponent? eComp =
        configs.engines.firstWhereOrNull((e) => e.version == engineVersion);
    if (eComp == null) {
      logs.add(
          "🐋 Could not find engine with specified version '$engineVersion'");
      return null;
    }
    final File engineFile = File(eComp.path);
    if (!(await engineFile.exists())) {
      logs.add(
          "🐋 Could not find an engine at the specified path '${eComp.path}'");
      return null;
    } else {
      logs.add("Running using engine from '${eComp.path}'...");
      final Directory appRootDir = Directory(aComp.path);
      if (!(await appRootDir.exists())) {
        logs.add(
            "🐋 Could not find an app at the specified path '${aComp.path}'");
        return null;
      }
      final Process proc = await Process.start(
        eComp.path,
        [
          'run',
          // '--release',
          '-d',
          'chrome',
        ],
        workingDirectory: aComp.path,
      );
      logs.add("Piping STDOUT from app to runtime...");
      proc.stdout.transform(utf8.decoder).listen((event) => logs.add(event));
      logs.add("🐋 Runtime successfully created!");
      return proc;
    }
  }

  Map<String, Object?> toJson() => {
        'configs': configs.toJson(),
        'appName': appName,
        'engineVersion': engineVersion,
        'serviceNames': serviceNames,
        'address': 'NA',
        'logs': logs,
      };
}

part of orca_core;

@HiveType(typeId: 3)
class OrcaRuntime extends HiveObject {
  @HiveField(0)
  final OrcaSpec orcaSpec;
  @HiveField(1)
  final String appName;
  @HiveField(2)
  final String engineVersion;
  @HiveField(3)
  final List<Map<String, dynamic>> services;
  // late final Uri address;
  @HiveField(4)
  final List<String> logs = [];
  @HiveField(5)
  final Map<String, Process> subprocesses = {};
  @HiveField(6)
  final Map<String, List<String>> subprocLogs = {};

  OrcaRuntime({
    required this.orcaSpec,
    required this.appName,
    required this.engineVersion,
    required this.services,
  });

  String get id =>
      '$appName-$engineVersion-${DateTime.now().millisecondsSinceEpoch}';

  OrcaRuntime.fromJson(Map<String, dynamic> data)
      : appName = data['appName'],
        engineVersion = data['engineVersion'],
        services = (data['services'] as List).cast<Map<String, dynamic>>(),
        orcaSpec = OrcaSpec.fromJson(data['orcaspec']) {
    if (data.containsKey('logs')) {
      logs.addAll((data['logs'] as List).cast<String>());
    }
  }

  Future<Process?> provisionSubproc({
    required String procId,
    required List<String> cmd,
    String? workingDir,
  }) async {
    subprocLogs[procId] = [];
    final Process subproc = await Process.start(
      cmd[0],
      cmd.sublist(1),
      workingDirectory: workingDir,
    )
      ..stdout
          .transform(utf8.decoder)
          .listen((event) => subprocLogs[procId]!.add(event));

    return subprocesses[procId] = subproc;
  }

  Future<Process?> spawn() async {
    /* if (orcaSpec == null) {
      logs.add("🐋 Could not find app with specified name '$appName'");
      return null;
    } */

    if (services.isNotEmpty) {
      for (final svc in services) {
        if (svc['name'] == 'firebase') {
          logs.add(
              "🐋 Provisioning subprocess for firebase service (${svc['version']})...");

          await provisionSubproc(
            procId: '${svc['name']}${svc['version']}',
            cmd: ['firebase', 'emulators:start', ...svc['startOptions']],
            workingDir:
                path.normalize("${orcaSpec.path}/${svc['databaseRootDir']}"),
          );

          logs.add("🐋 Successfully provisioned subprocess!");
        } else {
          logs.add("🐋 Could not load service named '${svc['name']}'.");
          return null;
        }
      }
    }

    final EngineComponent? eComp = OrcaCore.engines.values
        .firstWhereOrNull((e) => e.version == engineVersion);
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
      logs.add("🐋 Running using engine from '${eComp.path}'...");
      final Directory appRootDir = Directory(orcaSpec.path);
      if (!(await appRootDir.exists())) {
        logs.add(
            "🐋 Could not find an app at the specified path '${orcaSpec.path}'");
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
        workingDirectory: orcaSpec.path,
      );
      logs.add("🐋 Piping STDOUT from app to runtime...");
      proc.stdout.transform(utf8.decoder).listen((event) => logs.add(event));
      logs.add("🐋 Runtime successfully created!");
      return proc;
    }
  }

  Map<String, Object?> toJson() => {
        'orcaspec': orcaSpec.toJson(),
        'appName': appName,
        'engineVersion': engineVersion,
        'services': services,
        'address': 'NA',
        'logs': logs,
      };
}

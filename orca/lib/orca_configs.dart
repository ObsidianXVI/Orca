part of orca;

class OrcaConfigs {
  final String flutterPath;
  final List<OrcaAppConfig> apps;

  const OrcaConfigs({
    required this.flutterPath,
    required this.apps,
  });

  OrcaConfigs.fromJson(JSON jsonConfigs)
      : flutterPath = jsonConfigs['flutterPath'],
        apps = (jsonConfigs['apps'] as List)
            .map(
              (json) => OrcaAppConfig(
                appName: json['appName'],
                version: json['version'],
                path: json['path'],
              ),
            )
            .toList();

  JSON toJson() => {
        'flutterPath': flutterPath,
        'apps': apps.map((e) => e.toJson()).toList(),
      };
}

abstract class OrcaConfigComponent {
  const OrcaConfigComponent();

  JSON toJson();
}

class OrcaAppConfig extends OrcaConfigComponent {
  final String appName;
  final String version;
  final String path;

  const OrcaAppConfig({
    required this.appName,
    required this.version,
    required this.path,
  });

  @override
  JSON toJson() => {
        'appName': appName,
        'version': version,
        'path': path,
      };
}

part of orca;

class OrcaConfigs {
  final String flutterPath;
  final List<AppComponent> apps;

  const OrcaConfigs({
    required this.flutterPath,
    required this.apps,
  });

  OrcaConfigs.fromJson(JSON jsonConfigs)
      : flutterPath = jsonConfigs['flutterPath'],
        apps = (jsonConfigs['apps'] as List)
            .map(
              (json) => AppComponent(
                appName: json['appName'],
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

class AppComponent extends OrcaConfigComponent {
  final String appName;
  final String path;

  const AppComponent({
    required this.appName,
    required this.path,
  });

  @override
  JSON toJson() => {
        'appName': appName,
        'path': path,
      };
}

class OrcaAppConfig {
  final List<String> commands;

  const OrcaAppConfig({
    required this.commands,
  });

  OrcaAppConfig.fromJson(JSON jsonConfigs)
      : commands = (jsonConfigs['commands'] as List).cast<String>();
}

part of orca_core;

class OrcaConfigs {
  final List<AppComponent> apps;
  final List<EngineComponent> engines;
  final List<ServiceComponent> services;

  const OrcaConfigs({
    required this.apps,
    required this.engines,
    required this.services,
  });

  OrcaConfigs.fromJson(JSON jsonConfigs)
      : apps = (jsonConfigs['apps'] as List)
            .map((json) => AppComponent.fromJson(json))
            .toList(),
        engines = (jsonConfigs['engines'] as Map)
            .entries
            .map((e) => EngineComponent(
                  version: e.key,
                  path: e.value,
                ))
            .toList(),
        services = (jsonConfigs['services'] as List)
            .map((json) => ServiceComponent.fromJson(json))
            .toList();

  JSON toJson() => {
        'apps': apps.map((e) => e.toJson()).toList(),
        'engines': engines.map((e) => e.toJson()).toList(),
        'services': services.map((e) => e.toJson()).toList(),
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

  AppComponent.fromJson(JSON jsonConfigs)
      : appName = jsonConfigs['name'],
        path = jsonConfigs['path'];

  @override
  JSON toJson() => {
        'name': appName,
        'path': path,
      };
}

class EngineComponent extends OrcaConfigComponent {
  final String version;
  final String path;

  const EngineComponent({
    required this.version,
    required this.path,
  });

  EngineComponent.fromJson(JSON jsonConfigs)
      : version = jsonConfigs['version'],
        path = jsonConfigs['path'];

  @override
  JSON toJson() => {
        'version': version,
        'path': path,
      };
}

class ServiceComponent extends OrcaConfigComponent {
  final String name;
  final List<ServiceComponentEntry> componentEntries;

  const ServiceComponent({
    required this.name,
    required this.componentEntries,
  });

  static ServiceComponent fromJson(JSON jsonConfigs) {
    final String name = jsonConfigs['name'];
    final List<ServiceComponentEntry> entries = [];
    for (int i = 0; i < jsonConfigs['versions'].length; i++) {
      entries.add(ServiceComponentEntry(
        version: jsonConfigs['versions'][i],
        path: jsonConfigs['paths'][i],
      ));
    }
    return ServiceComponent(name: name, componentEntries: entries);
  }

  @override
  JSON toJson() {
    final List<String> versions = [for (final e in componentEntries) e.version];
    final List<String> paths = [for (final e in componentEntries) e.path];
    return {
      'name': name,
      'versions': versions,
      'paths': paths,
    };
  }
}

class ServiceComponentEntry {
  final String version;
  final String path;

  const ServiceComponentEntry({
    required this.version,
    required this.path,
  });
}

class OrcaAppConfig {
  final List<String> commands;

  const OrcaAppConfig({
    required this.commands,
  });

  OrcaAppConfig.fromJson(JSON jsonConfigs)
      : commands = (jsonConfigs['commands'] as List).cast<String>();
}

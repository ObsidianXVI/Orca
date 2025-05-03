part of orca_core;

class OrcaConfigs {
  final List<AppComponent> apps;
  final List<EngineComponent> engines;
  final List<ServiceComponent> services;
  final String configsPath;

  const OrcaConfigs({
    required this.apps,
    required this.engines,
    required this.services,
    required this.configsPath,
  });

  OrcaConfigs.fromJson(
    JSON jsonConfigs, {
    required this.configsPath,
  })  : apps = (jsonConfigs['apps'] as List)
            .map((json) => AppComponent.fromJson(json))
            .toList(),
        engines = (jsonConfigs['engines'] as List)
            .map((e) => EngineComponent.fromJson(e as Map<String, dynamic>))
            .toList(),
        services = (jsonConfigs['services'] as List)
            .map((json) => ServiceComponent.fromJson(json))
            .toList();

  JSON toJson() => {
        'apps': apps.map((e) => e.toJson()).toList(),
        'engines': engines.map((e) => e.toJson()).toList(),
        'services': services.map((e) => e.toJson()).toList(),
        'configsPath': configsPath,
      };
}

abstract class OrcaConfigComponent {
  const OrcaConfigComponent();

  JSON toJson();
}

class AppComponent extends OrcaConfigComponent {
  final String appName;
  final String path;
  final String engine;
  final List<ServiceComponent> services;

  const AppComponent({
    required this.appName,
    required this.path,
    required this.engine,
    this.services = const [],
  });

  static AppComponent fromJson(JSON jsonConfigs) {
    final String appName = jsonConfigs['name'];
    final String path = jsonConfigs['path'];
    final String engine = jsonConfigs['engine'];
    final List<ServiceComponent> services = [];
    for (int i = 0; i < jsonConfigs['services'].length; i++) {
      services.add(ServiceComponent(
        name: jsonConfigs['services'][i]['name'],
        componentEntries: [],
      ));
    }
    return AppComponent(
      appName: appName,
      path: path,
      engine: engine,
      services: services,
    );
  }

  @override
  JSON toJson() => {
        'name': appName,
        'path': path,
        'engine': engine,
        'services': services.map((svc) => svc.toJson()).toList(),
      };

  @override
  bool operator ==(Object? other) =>
      (other is AppComponent) && other.appName == appName && other.path == path;

  @override
  int get hashCode => "$appName$path".hashCode;
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

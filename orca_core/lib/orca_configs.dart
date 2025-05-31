part of orca_core;

/// The component of the orcaspec that specifies the app's requirements
@HiveType(typeId: 0)
class OrcaSpec extends HiveObject {
  /// The app's display name.
  @HiveField(0)
  final String appName;

  /// The project directory's path on the machine.
  @HiveField(1)
  final String path;

  /// The version of the Flutter SDK to use. '*' means any version.
  @HiveField(2)
  final String engine;

  /// The list of services the app requires access to.
  @HiveField(3)
  final List<ServiceComponent> services;

  String get id => appName;

  OrcaSpec({
    required this.appName,
    required this.path,
    required this.engine,
    this.services = const [],
  });

  static OrcaSpec fromJson(JSON jsonConfigs) {
    final String appName = jsonConfigs['name'];
    final String engine = jsonConfigs['engine'];
    final List<ServiceComponent> services = [];
    for (int i = 0; i < jsonConfigs['services'].length; i++) {
      services.add(ServiceComponent.fromJson(jsonConfigs['services'][i]));
    }
    return OrcaSpec(
      appName: appName,
      path: jsonConfigs.containsKey('path') ? jsonConfigs['path'] : '<NULL>',
      engine: engine,
      services: services,
    );
  }

  JSON toJson() => {
        'name': appName,
        'path': path,
        'engine': engine,
        'services': services.map((svc) => svc.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      (other is OrcaSpec) && other.appName == appName && other.path == path;

  @override
  int get hashCode => "$appName$path".hashCode;
}

@HiveType(typeId: 2)
class EngineComponent extends HiveObject {
  @HiveField(0)
  final String version;
  @HiveField(1)
  final String path;

  EngineComponent({
    required this.version,
    required this.path,
  });

  EngineComponent.fromJson(JSON jsonConfigs)
      : version = jsonConfigs['version'],
        path = jsonConfigs['path'];

  String get id => 'engine-$version--$path';

  JSON toJson() => {
        'version': version,
        'path': path,
      };
}

@HiveType(typeId: 1)
class ServiceComponent extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String version;
  @HiveField(2)
  final List<ServicePermissionEntry> permissionEntries;

  ServiceComponent({
    required this.name,
    required this.version,
    required this.permissionEntries,
  });

  static ServiceComponent fromJson(JSON jsonConfigs) {
    final String name = jsonConfigs['name'];
    final String version = jsonConfigs['version'];
    final List<ServicePermissionEntry> permissions = [];
    /* for (int i = 0; i < jsonConfigs['permissions'].length; i++) {
      permissions.add(ServicePermissionEntry(jsonConfigs['permissions'][i]));
    } */
    return ServiceComponent(
      name: name,
      version: version,
      permissionEntries: permissions,
    );
  }

  String get id => '$name-$version';

  JSON toJson() => {
        'name': name,
        'version': version,
        'permissions': [for (final e in permissionEntries) e.permId],
      };
}

@HiveType(typeId: 4)
class ServicePermissionEntry {
  @HiveField(0)
  final String permId;

  const ServicePermissionEntry(this.permId);
}

class OrcaAppConfig {
  final List<String> commands;

  const OrcaAppConfig({
    required this.commands,
  });

  OrcaAppConfig.fromJson(JSON jsonConfigs)
      : commands = (jsonConfigs['commands'] as List).cast<String>();
}

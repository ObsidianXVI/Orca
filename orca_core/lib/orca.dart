library orca_core;

import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

part './orca_configs.dart';
part './orca_runtime.dart';
part './exceptions.dart';
part './result.dart';

typedef JSON = Map<String, dynamic>;

enum AppSourceType {
  git,
  local,
}

class OrcaCore {
  static late OrcaConfigs orcaConfigs;
  static late final HttpServer server;
  static final Map<OrcaRuntime, Process> runtimes = {};

  static Future<void> init(OrcaConfigs configs) async {
    ProcessSignal.sigint.watch().listen((signal) {
      print("SIGINT detected, gracefully shutting down daemon...");
      deinit();
    });
    orcaConfigs = configs;
    server = await HttpServer.bind(InternetAddress.anyIPv4, 8082);
    print(
        "Server listening on ${Uri(scheme: 'http', host: server.address.host, port: server.port)}");
    server.listen((HttpRequest req) async {
      if (req.uri.pathSegments.isNotEmpty) {
        if (req.uri.pathSegments.length <= 1) {
          req.response.fromOrcaResult(
            OrcaResult.insufficientPathLengthOfRequest(req.uri.pathSegments[0]),
          );
        } else {}
        try {
          switch (req.uri.pathSegments[0]) {
            case 'apps':
              switch (req.uri.pathSegments[1]) {
                case 'list':
                  req.response.fromOrcaResult(appsList());
                  break;
                case 'create':
                  req.response.fromOrcaResult(await appsCreate(
                    req.uri.queryParameters.get<String>('source'),
                    AppSourceType.local,
                  ));
                  break;
                case 'delete':
                  req.response.fromOrcaResult(await appsCreate(
                    req.uri.queryParameters.get<String>('source'),
                    AppSourceType.local,
                  ));
                  break;
              }
              break;
            case 'engines':
              switch (req.uri.pathSegments[1]) {
                case 'list':
                  req.response.fromOrcaResult(enginesList());
                  break;
                case 'create':
                  req.response.fromOrcaResult(await enginesCreate(
                    req.uri.queryParameters.get<String>('version'),
                    req.uri.queryParameters.get<String>('source'),
                  ));
                  break;
              }
              break;
            case 'services':
              switch (req.uri.pathSegments[1]) {
                case 'list':
                  req.response.fromOrcaResult(servicesList());
                  break;
                case 'create':
                  req.response.fromOrcaResult(await servicesCreate(
                    req.uri.queryParameters.get<String>('name'),
                  ));
                  break;
                case 'add':
                  req.response.fromOrcaResult(await servicesAdd(
                    req.uri.queryParameters.get<String>('name'),
                    req.uri.queryParameters.get<String>('version'),
                    req.uri.queryParameters.get<String>('path'),
                  ));
                  break;
              }
              break;
            case 'runtimes':
              switch (req.uri.pathSegments[1]) {
                case 'list':
                  req.response.fromOrcaResult(runtimesList());
                  break;
                case 'create':
                  print(req.uri.queryParameters['services']);
                  req.response.fromOrcaResult(await runtimesCreate(
                    req.uri.queryParameters.get<String>('appName'),
                    req.uri.queryParameters.get<String>('engineVersion'),
                    [],
                  ));
                  break;
                case 'delete':
                  req.response.fromOrcaResult(runtimesDelete(
                    req.uri.queryParameters.get<String>('appName'),
                  ));
                  break;
              }
              break;
            case 'app':
              switch (req.uri.pathSegments[1]) {
                case 'get':
                  req.response.fromOrcaResult(await appDetails(
                    req.uri.queryParameters.get<String>('appName'),
                  ));
                  break;
                case 'setup':
                  req.response.fromOrcaResult(await appSetup(
                    req.uri.queryParameters.get<String>('appName'),
                  ));
                  break;
              }
              break;
          }
        } on OrcaException catch (e) {
          req.response
            ..statusCode = 400
            ..headers.set('Access-Control-Allow-Origin', '*')
            ..write(
              jsonEncode({
                'statusCode': 400,
                ...e.toJson(),
              }),
            );
        }
      } else {
        req.response
          ..headers.set('Access-Control-Allow-Origin', '*')
          ..statusCode = 200;
      }
      req.response.close();
    });
  }

  static void deinit() {
    print("Teriminating ${runtimes.length} remaining runtimes...");

    for (MapEntry<OrcaRuntime, Process> runtime in runtimes.entries) {
      print("  Terminating runtime for '${runtime.key.appName}'...");
      runtime.value.kill();
      print("    Done");
    }

    print("✅ Daemon shutdown sequence completed!");
    exit(0);
  }

  /// Lists all the available app configurations.
  static OrcaResult appsList() => OrcaResult(
        statusCode: 200,
        payload: [for (final a in orcaConfigs.apps) a.toJson()],
      );

  /// Lists all the available app configurations.
  static OrcaResult enginesList() => OrcaResult(
        statusCode: 200,
        payload: [for (final a in orcaConfigs.engines) a.toJson()],
      );

  /// Lists all available service configurations.
  static OrcaResult servicesList() => OrcaResult(
        statusCode: 200,
        payload: [for (final a in orcaConfigs.services) a.toJson()],
      );

  /// Lists all available runtimes.
  static OrcaResult runtimesList() => OrcaResult(
      statusCode: 200,
      payload: [for (final a in runtimes.entries) a.key.toJson()]);

  /// Creates an app configuration with the given path/URL and app type.
  /// Currently only [AppSourceType.local] is allowed.
  static Future<OrcaResult> appsCreate(
    String source,
    AppSourceType sourceType,
  ) async {
    if (sourceType == AppSourceType.git) {
      return OrcaResult(
        statusCode: 400,
        exception: OrcaException(
          exceptionLevel: ExceptionLevel.error,
          message: "Git not supported",
        ),
      );
    } else {
      final Directory rootDir = Directory(source);
      final bool exists = await rootDir.exists();
      if (exists) {
        final bool hasPubspec =
            await File(path.join(rootDir.path, 'pubspec.yaml')).exists();
        final bool hasOrcaspec =
            await File(path.join(rootDir.path, 'orcaspec.json')).exists();
        if (hasPubspec && hasOrcaspec) {
          final String appName = path.split(source).last;
          orcaConfigs.apps.add(
            AppComponent(appName: appName, path: source),
          );
          await File(orcaConfigs.configsPath)
              .writeAsString(jsonEncode(orcaConfigs.toJson()));
          return OrcaResult(statusCode: 200, payload: {'appName': appName});
        } else {
          return OrcaResult(
            statusCode: 405,
            exception: OrcaException(
              message:
                  "Could not verify the presence of either pubspec, orcaspec, or both.",
              exceptionLevel: ExceptionLevel.error,
            ),
          );
        }
      } else {
        return OrcaResult(
          statusCode: 404,
          exception: OrcaException(
            message: "Directory not found on specified path '${rootDir.path}'.",
            exceptionLevel: ExceptionLevel.error,
          ),
        );
      }
    }
  }

  static Future<OrcaResult> appsDelete(String name) async {
    final AppComponent? appToDelete =
        orcaConfigs.apps.firstWhereOrNull((app) => app.appName == name);
    if (appToDelete == null) {
      return OrcaResult(
        statusCode: 404,
        exception: OrcaException(
          message: "App with specified name '$name' not found.",
          exceptionLevel: ExceptionLevel.error,
        ),
      );
    } else {
      orcaConfigs.apps.remove(appToDelete);
      await File(orcaConfigs.configsPath)
          .writeAsString(jsonEncode(orcaConfigs.toJson()));
      return OrcaResult(statusCode: 200);
    }
  }

  /// Creates an engine configuration with the given version and path.
  static Future<OrcaResult> enginesCreate(
          String version, String source) async =>
      OrcaResult(statusCode: 200);

  /// Creates an empty service configuration with the given name.
  static Future<OrcaResult> servicesCreate(String name) async =>
      OrcaResult(statusCode: 200);

  /// Adds a version and path configuration to an existing service.
  static Future<OrcaResult> servicesAdd(
    String name,
    String version,
    String source,
  ) async =>
      OrcaResult(statusCode: 200);

  /// Creates a runtime.
  static Future<OrcaResult> runtimesCreate(
    String appName,
    String engineVersion,
    List<String> serviceNames,
  ) async {
    final OrcaRuntime orcaRuntime = OrcaRuntime(
      configs: orcaConfigs,
      appName: appName,
      engineVersion: engineVersion,
      serviceNames: serviceNames,
    );
    final Process? proc = await orcaRuntime.spawn();
    if (proc == null) {
      return OrcaResult(
        statusCode: 400,
        payload: orcaRuntime.logs.join('\n'),
        exception: OrcaException(
          message: 'Runtime creation failed',
          exceptionLevel: ExceptionLevel.error,
        ),
      );
    } else {
      print("PID: ${proc.pid}");
      runtimes[orcaRuntime] = proc;
      return OrcaResult(statusCode: 200);
    }
  }

  static OrcaResult runtimesDelete(String appName) {
    for (MapEntry<OrcaRuntime, Process> rt in runtimes.entries) {
      if (rt.key.appName == appName) {
        rt.value.kill();
        return OrcaResult(statusCode: 200);
      }
    }

    return OrcaResult(
      statusCode: 400,
      exception: OrcaException(
        message:
            "Runtime for '$appName' could not be deleted as it does not exist",
        exceptionLevel: ExceptionLevel.error,
      ),
    );
  }

  static Future<OrcaResult> appDetails(String appName) async {
    final AppComponent? appComponent =
        orcaConfigs.apps.firstWhereOrNull((app) => app.appName == appName);
    if (appComponent != null) {
      final Directory appDir = Directory(appComponent.path);
      if (await appDir.exists()) {
        final Map<String, dynamic> appDetails = {};
        final File orcaspec =
            File(path.join(appComponent.path, 'orcaspec.json'));
        if (await orcaspec.exists()) {
          appDetails.addAll(jsonDecode(await orcaspec.readAsString()));
        } else {
          print('no orcaspec');
        }
        return OrcaResult(statusCode: 200, payload: appDetails);
      } else {
        return OrcaResult(
          statusCode: 404,
          exception: OrcaException(
            message:
                "App with name '$appName' could not be found at path '${appComponent.path}'.",
            exceptionLevel: ExceptionLevel.error,
          ),
        );
      }
    } else {
      return OrcaResult(
        statusCode: 404,
        exception: OrcaException(
          message: "App with name '$appName' not found.",
          exceptionLevel: ExceptionLevel.error,
        ),
      );
    }
  }

  static Future<OrcaResult> appSetup(String appName) async {
    final AppComponent? appComponent =
        orcaConfigs.apps.firstWhereOrNull((app) => app.appName == appName);
    if (appComponent != null) {
      final Directory appDir = Directory(appComponent.path);
      if (await appDir.exists()) {
        final File orcaspec = File("${appComponent.path}/orcaspec.json");
        final String engineVersion;
        final List<JSON> services;
        if (await orcaspec.exists()) {
          final JSON orcaspecData = jsonDecode(await orcaspec.readAsString());
          engineVersion = orcaspecData['engine'];
          services = orcaspecData['services'].cast<JSON>();
        } else {
          engineVersion = '*';
          services = [];
        }
        for (final svc in services) {
          if (svc['name'] == 'firebase') {
            final ServiceComponent? fbComp = orcaConfigs.services
                .firstWhereOrNull((comp) => comp.name == 'firebase');
            if (fbComp == null) {
              return OrcaResult(
                statusCode: 418,
                exception: OrcaException(
                  message:
                      "Service named 'firebase' (v${svc['version']}) required by app, but user does not have the firebase service specified in the orca_configs.json. Try downloading the Firebase SDK and adding it to the orca_configs.json file.",
                  exceptionLevel: ExceptionLevel.error,
                ),
              );
            } else {
              for (final entry in fbComp.componentEntries) {
                if (svc['version'] == '*' || entry.version == svc['version']) {
                  if (await File(entry.path).exists()) {
                    return OrcaResult(statusCode: 200);
                  } else {
                    return OrcaResult(
                      statusCode: 418,
                      exception: OrcaException(
                        message:
                            "Path specified for Firebase v${entry.version} (${entry.path}) does not exist. Try updating the path in the orca_configs.json file.",
                        exceptionLevel: ExceptionLevel.error,
                      ),
                    );
                  }
                }
              }
              return OrcaResult(
                statusCode: 418,
                exception: OrcaException(
                  message:
                      "Service named 'firebase' (v${svc['version']}) required by app, but user does not have a matching version specified in the orca_configs.json. Try downloading the Firebase SDK and adding it to the orca_configs.json file.",
                  exceptionLevel: ExceptionLevel.error,
                ),
              );
            }
          }
        }
        for (final engComp in orcaConfigs.engines) {
          if (engineVersion == '*' || engComp.version == engineVersion) {
            return OrcaResult(statusCode: 200);
          } else {
            return OrcaResult(
              statusCode: 418,
              exception: OrcaException(
                message:
                    "Engine(v$engineVersion) required by app, but user does not have a matching version specified in the orca_configs.json. Try downloading the Flutter SDK and adding it to the orca_configs.json file.",
                exceptionLevel: ExceptionLevel.error,
              ),
            );
          }
        }
        return OrcaResult(statusCode: 200);
      } else {
        return OrcaResult(
          statusCode: 404,
          exception: OrcaException(
            message:
                "App with name '$appName' could not be found at path '${appComponent.path}'.",
            exceptionLevel: ExceptionLevel.error,
          ),
        );
      }
    } else {
      return OrcaResult(
        statusCode: 404,
        exception: OrcaException(
          message: "App with name '$appName' not found.",
          exceptionLevel: ExceptionLevel.error,
        ),
      );
    }
  }
}

extension QueryParamUtils on Map<String, String> {
  T get<T>(
    String name, {
    T Function(String)? converter,
    String? errMsg,
  }) {
    if (containsKey(name)) {
      try {
        if (converter != null) {
          return converter(this[name]!);
        } else {
          return this[name] as T;
        }
      } catch (e) {
        throw "Expected '$name' to be convertible to '$T'.";
      }
    } else {
      throw OrcaException(
        message: errMsg ?? "Expected parameter with name '$name'.",
        payload: this[name],
        exceptionLevel: ExceptionLevel.error,
      );
    }
  }
}

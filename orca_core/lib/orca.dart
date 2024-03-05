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
  static final Map<String, Process> runtimes = {};

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
                  req.response.fromOrcaResult(await runtimesCreate(
                    req.uri.queryParameters.get<String>('appName'),
                    req.uri.queryParameters.get<String>('engineVersion'),
                    [], // idk how to parse a list from HTTP query param
                  ));
                  break;
                case 'delete':
                  req.response.fromOrcaResult(runtimesDelete(
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
              jsonEncode(e.toJson()),
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
    final Iterable<MapEntry<String, Process>> runtimeEntries = runtimes.entries;
    print("Teriminating ${runtimeEntries.length} remaining runtimes...");

    for (MapEntry<String, Process> runtime in runtimeEntries) {
      print("  Terminating runtime for '${runtime.key}'...");
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
  static OrcaResult runtimesList() => OrcaResult(statusCode: 200);

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
          return OrcaResult(statusCode: 200);
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
            message: "Directory not found on specified path.",
            exceptionLevel: ExceptionLevel.error,
          ),
        );
      }
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
      runtimes[appName] = proc;
      return OrcaResult(statusCode: 200);
    }
  }

  static OrcaResult runtimesDelete(String appName) {
    if (runtimes.containsKey(appName)) {
      runtimes[appName]!.kill();
      return OrcaResult(statusCode: 200);
    } else {
      return OrcaResult(
        statusCode: 400,
        exception: OrcaException(
          message:
              "Runtime for '$appName' could not be deleted as it does not exist",
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

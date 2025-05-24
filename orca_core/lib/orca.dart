library orca_core;

import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';

import 'package:http_apis_define/http_apis.dart';

part 'orca.g.dart';
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
  static late Box<OrcaSpec> apps;
  static late Box<ServiceComponent> services;
  static late Box<EngineComponent> engines;
  static late Box<OrcaRuntime> runtimes;
  static late Box<Map<String, dynamic>> configs;
  static late final HttpServer server;
  static final Map<String, Process> processes = {};
  static final API api = API(
    apiName: 'orca-api',
    routes: [
      RouteSegment.routes(
        routeName: 'apps',
        routes: [
          RouteSegment.endpoint(
            routeName: 'list',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.get],
              queryParameters: [],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                writeBody(jsonEncode({
                  "payload": [for (final a in apps.values) a.toJson()],
                }));
                return HttpStatus.ok;
              },
              requiresAuth: false,
            ),
          ),
          RouteSegment.endpoint(
            routeName: 'create',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.post],
              queryParameters: [
                Param<String, String>.required(
                  'source',
                  desc: "The path of the project root directory.",
                  cast: (obj) => obj as String,
                )
              ],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final String source = getParam<String>('source')!;
                final Directory rootDir = Directory(source);
                final bool exists = await rootDir.exists();
                if (!exists) {
                  raise(HttpStatus.notFound,
                      "Directory not found on specified path '");
                  return HttpStatus.notFound;
                }
                final bool hasPubspec =
                    await File(path.join(rootDir.path, 'pubspec.yaml'))
                        .exists();
                final bool hasOrcaspec =
                    await File(path.join(rootDir.path, 'orcaspec.json'))
                        .exists();
                if (hasPubspec && hasOrcaspec) {
                  final OrcaSpec res;
                  final String appName = path.split(source).last;
                  res = OrcaSpec(appName: appName, path: source, engine: '*');
                  apps.put(res.id, res);

                  writeBody(jsonEncode(res.toJson()));
                  return HttpStatus.ok;
                } else {
                  raise(HttpStatus.notFound,
                      "Insufficient config files at target project directory: orcaspec ${hasOrcaspec ? '✅' : '❌'}, pubspec ${hasPubspec ? '✅' : '❌'}.");
                  return HttpStatus.notFound;
                }
              },
              requiresAuth: false,
            ),
          ),
          RouteSegment.endpoint(
            routeName: 'delete',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.post],
              queryParameters: [
                Param<String, String>.required(
                  'name',
                  desc: "The name of the app to delete.",
                  cast: (obj) => obj as String,
                )
              ],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final String name = getParam<String>('name')!;
                if (apps.containsKey(name)) {
                  apps.delete(name);
                  return HttpStatus.ok;
                } else {
                  raise(HttpStatus.notFound,
                      "App with specified name '$name' not found.");
                  return HttpStatus.notFound;
                }
              },
              requiresAuth: false,
            ),
          ),
        ],
      ),
      RouteSegment.routes(
        routeName: 'engines',
        routes: [
          RouteSegment.endpoint(
            routeName: 'list',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.get],
              queryParameters: [],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                writeBody(jsonEncode({
                  "payload": [for (final e in engines.values) e.toJson()],
                }));
                return HttpStatus.ok;
              },
              requiresAuth: false,
            ),
          ),
          RouteSegment.endpoint(
            routeName: 'create',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.post],
              queryParameters: [
                Param<String, String>.required(
                  'version',
                  desc: "The version of the engine.",
                  cast: (obj) => obj as String,
                ),
                Param<String, String>.required(
                  'source',
                  desc: "The source path of the engine.",
                  cast: (obj) => obj as String,
                )
              ],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                // Implementation for engine creation
                return HttpStatus.ok;
              },
              requiresAuth: false,
            ),
          ),
        ],
      ),
      RouteSegment.routes(
        routeName: 'services',
        routes: [
          RouteSegment.endpoint(
            routeName: 'list',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.get],
              queryParameters: [],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                writeBody(jsonEncode({
                  "payload": [for (final s in services.values) s.toJson()],
                }));
                return HttpStatus.ok;
              },
              requiresAuth: false,
            ),
          ),
          RouteSegment.endpoint(
            routeName: 'create',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.post],
              queryParameters: [
                Param<String, String>.required(
                  'name',
                  desc: "The name of the service to create.",
                  cast: (obj) => obj as String,
                ),
                Param<String, String>.required(
                  'version',
                  desc: "The version number of the service.",
                  cast: (obj) => obj as String,
                )
              ],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final String name = getParam<String>('name')!;
                final svcComp = ServiceComponent(
                  name: name,
                  permissionEntries: [],
                  version: getParam('version'),
                );
                services.put(svcComp.id, svcComp);
                return HttpStatus.ok;
              },
              requiresAuth: false,
            ),
          ),
        ],
      ),
      RouteSegment.routes(
        routeName: 'runtimes',
        routes: [
          RouteSegment.endpoint(
            routeName: 'list',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.get],
              queryParameters: [],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                writeBody(jsonEncode({
                  "payload": [for (final a in runtimes.values) a.toJson()],
                }));
                return HttpStatus.ok;
              },
              requiresAuth: false,
            ),
          ),
          RouteSegment.endpoint(
            routeName: 'create',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.post],
              queryParameters: [
                Param<String, String>.required(
                  'appName',
                  desc: "The name of the app for which to create a runtime.",
                  cast: (obj) => obj as String,
                ),
                Param<String, String>.required(
                  'engineVersion',
                  desc: "The version of the engine to use.",
                  cast: (obj) => obj as String,
                ),
                Param<OrcaSpec, JSON>.required(
                  'orcaspec',
                  desc: 'Orcaspec for the app to be run.',
                  cast: (obj) => OrcaSpec.fromJson(obj as JSON),
                ),
              ],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final String appName = getParam<String>('appName')!;
                final String engineVersion = getParam<String>('engineVersion')!;
                final OrcaRuntime runtime = OrcaRuntime(
                  orcaSpec: getParam('orcaspec'),
                  appName: appName,
                  engineVersion: engineVersion,
                  services: [],
                );
                final Process? proc = await runtime.spawn();
                if (proc == null) {
                  raise(HttpStatus.badRequest, 'Runtime creation failed.');
                  return HttpStatus.badRequest;
                } else {
                  processes[runtime.id] = proc;
                  return HttpStatus.created;
                }
              },
              requiresAuth: false,
            ),
          ),
          RouteSegment.endpoint(
            routeName: 'get',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.get],
              queryParameters: [
                Param<String, String>.required(
                  'appName',
                  desc: "The name of the app to retrieve runtime details for.",
                  cast: (obj) => obj as String,
                )
              ],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final String appName = getParam<String>('appName')!;
                final runtime = runtimes.values
                    .firstWhereOrNull((entry) => entry.appName == appName);
                if (runtime == null) {
                  raise(HttpStatus.notFound, "Runtime not found.");
                  return HttpStatus.notFound;
                }
                writeBody(jsonEncode(runtime.toJson()));
                return HttpStatus.ok;
              },
              requiresAuth: false,
            ),
          ),
          RouteSegment.endpoint(
            routeName: 'delete',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.post],
              queryParameters: [
                Param<String, String>.required(
                  'appName',
                  desc: "The name of the app whose runtime is to be deleted.",
                  cast: (obj) => obj as String,
                )
              ],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final String appName = getParam<String>('appName')!;
                final runtime = runtimes.values
                    .firstWhereOrNull((entry) => entry.appName == appName);
                if (runtime == null) {
                  raise(HttpStatus.notFound, "Runtime not found.");
                  return HttpStatus.notFound;
                }
                processes[runtime.id]?.kill();
                runtimes.delete(runtime.id);
                return HttpStatus.ok;
              },
              requiresAuth: false,
            ),
          ),
        ],
      ),
      RouteSegment.routes(
        routeName: 'app',
        routes: [
          RouteSegment.endpoint(
            routeName: 'get',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.get],
              queryParameters: [
                Param<String, String>.required(
                  'appName',
                  desc: "The name of the app to retrieve details for.",
                  cast: (obj) => obj as String,
                )
              ],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final String appName = getParam<String>('appName')!;
                if (!apps.containsKey(appName)) {
                  raise(HttpStatus.notFound, "App not found.");
                  return HttpStatus.notFound;
                } else {
                  writeBody(jsonEncode(apps.get(appName)!.toJson()));
                  return HttpStatus.ok;
                }
              },
              requiresAuth: false,
            ),
          ),
          RouteSegment.endpoint(
            routeName: 'setup',
            endpoint: Endpoint(
              endpointTypes: [EndpointType.post],
              queryParameters: [
                Param<String, String>.required(
                  'appName',
                  desc: "The name of the app to set up.",
                  cast: (obj) => obj as String,
                )
              ],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required void Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final String appName = getParam<String>('appName')!;
                if (!apps.containsKey(appName)) {
                  raise(HttpStatus.notFound, "App not found.");
                  return HttpStatus.notFound;
                }
                final OrcaSpec app = apps.get(appName)!;
                final Directory appDir = Directory(app.path);
                if (!await appDir.exists()) {
                  raise(HttpStatus.notFound, "App directory not found.");
                  return HttpStatus.notFound;
                }
                final File orcaspec =
                    File(path.join(app.path, 'orcaspec.json'));
                if (!await orcaspec.exists()) {
                  raise(HttpStatus.badRequest, "Orcaspec file not found.");
                  return HttpStatus.badRequest;
                }
                final Map<String, dynamic> spec =
                    jsonDecode(await orcaspec.readAsString());
                writeBody(jsonEncode(spec));
                return HttpStatus.ok;
              },
              requiresAuth: false,
            ),
          ),
        ],
      ),
    ],
  );

  static Future<void> init() async {
    ProcessSignal.sigint.watch().listen((signal) {
      print("SIGINT detected, gracefully shutting down daemon...");
      deinit();
    });

    apps = await Hive.openBox<OrcaSpec>('apps', path: './');
    services = await Hive.openBox<ServiceComponent>('services', path: './');
    engines = await Hive.openBox<EngineComponent>('engines', path: './');
    runtimes = await Hive.openBox<OrcaRuntime>('runtimes', path: './');
    Hive
      ..registerAdapter(OrcaSpecAdapter())
      ..registerAdapter(EngineComponentAdapter())
      ..registerAdapter(ServiceComponentAdapter())
      ..registerAdapter(ServicePermissionEntryAdapter())
      ..registerAdapter(OrcaRuntimeAdapter());

    server = await HttpServer.bind(InternetAddress.anyIPv4, 8082);
    print(
        "Server listening on ${Uri(scheme: 'http', host: server.address.host, port: server.port)}");
    try {
      server.listen((HttpRequest req) async {
        if (req.uri.pathSegments.length > 1) {
          req.response.headers.set('Access-Control-Allow-Origin', '*');
          try {
            await api.handleRequest(req, pathSegmentOffset: 1);
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
        await req.response.close();
      });
    } catch (e, st) {
      print("FATAL ERROR CAUGHT");
      print(e);
      print(st);
      print('===');
      deinit();
    }
  }

  static void deinit() async {
    print("Teriminating ${runtimes.length} remaining runtimes...");
    for (OrcaRuntime runtime in runtimes.values) {
      print("  Terminating runtime for '${runtime.appName}'...");
      processes[runtime.id]?.kill();
      print("    Done");
    }

    print("Shutting down server...");
    await server.close();

    print("Shutting down database...");
    await apps.close();
    await services.close();
    await engines.close();
    await runtimes.close();

    print("✅ Daemon shutdown sequence completed!");
    exit(0);
  }

  /// Lists all the available app configurations.
  static OrcaResult appsList() => OrcaResult(
        statusCode: 200,
        payload: [for (final a in apps.values) a.toJson()],
      );

  /// Lists all the available app configurations.
  static OrcaResult enginesList() => OrcaResult(
        statusCode: 200,
        payload: [for (final a in engines.values) a.toJson()],
      );

  /// Lists all available service configurations.
  static OrcaResult servicesList() => OrcaResult(
        statusCode: 200,
        payload: [for (final a in services.values) a.toJson()],
      );

  /// Lists all available runtimes.
  static OrcaResult runtimesList() => OrcaResult(
      statusCode: 200, payload: [for (final a in runtimes.values) a.toJson()]);

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
          final OrcaSpec res =
              OrcaSpec(appName: appName, path: source, engine: '*');
          apps.put(res.id, res);
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
    if (!apps.containsKey(name)) {
      return OrcaResult(
        statusCode: 404,
        exception: OrcaException(
          message: "App with specified name '$name' not found.",
          exceptionLevel: ExceptionLevel.error,
        ),
      );
    } else {
      apps.delete(name);
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
      String appName, String engineVersion, OrcaSpec orcaspec) async {
    final OrcaResult appDetailsResult = await appDetails(appName);
    if (appDetailsResult.exception != null) return appDetailsResult;

    final OrcaRuntime orcaRuntime = OrcaRuntime(
      orcaSpec: orcaspec,
      appName: appName,
      engineVersion: engineVersion,
      services: appDetailsResult.payload['services'].cast<JSON>(),
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
      processes[orcaRuntime.id] = proc;
      return OrcaResult(statusCode: 200);
    }
  }

  static OrcaResult runtimesDelete(String appName) {
    for (OrcaRuntime rt in runtimes.values) {
      if (rt.appName == appName) {
        processes[rt.id]?.kill();
        runtimes.delete(rt.id);
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

  static Future<OrcaResult> runtimesGet(String appName) async {
    for (OrcaRuntime rt in runtimes.values) {
      if (rt.appName == appName) {
        return OrcaResult(statusCode: 200, payload: rt.toJson());
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
    if (apps.containsKey(appName)) {
      final OrcaSpec app = apps.get(appName)!;
      final Directory appDir = Directory(app.path);
      if (await appDir.exists()) {
        final Map<String, dynamic> appDetails = {};
        final File orcaspec = File(path.join(app.path, 'orcaspec.json'));
        if (await orcaspec.exists()) {
          appDetails.addAll(jsonDecode(await orcaspec.readAsString()));
        }
        return OrcaResult(statusCode: 200, payload: appDetails);
      } else {
        return OrcaResult(
          statusCode: 404,
          exception: OrcaException(
            message:
                "App with name '$appName' could not be found at path '${app.path}'.",
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
    if (apps.containsKey(appName)) {
      final OrcaSpec app = apps.get(appName)!;
      final Directory appDir = Directory(app.path);
      if (await appDir.exists()) {
        final File orcaspec = File("${app.path}/orcaspec.json");
        final String engineVersion;
        final List<JSON> svcs;
        if (await orcaspec.exists()) {
          final JSON orcaspecData = jsonDecode(await orcaspec.readAsString());
          engineVersion = orcaspecData['engine'];
          svcs = orcaspecData['services'].cast<JSON>();
        } else {
          engineVersion = '*';
          svcs = [];
        }
        for (final svc in svcs) {
          if (svc['name'] == 'firebase') {
            final ServiceComponent? fbComp = services.values
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
              /* for (final entry in fbComp.permissionEntries) {
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
              ); */
            }
          }
        }
        for (final engComp in engines.values) {
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
                "App with name '$appName' could not be found at path '${app.path}'.",
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

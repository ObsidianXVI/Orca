library orca_core;

import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';
import 'package:http_apis_secure/secure.dart' as secure;
import 'package:http_apis_define/http_apis.dart';

import 'dart:convert';
import 'dart:io';

part 'orca.g.dart';
part './orca_configs.dart';
part './orca_runtime.dart';
part './exceptions.dart';
part './result.dart';
part './battery_services/orca_fs.dart';

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
  static late Box<String> keys;
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
              authModel: AuthModel.classic_sym,
              endpointTypes: [EndpointType.get],
              queryParameters: [],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required int Function(int, String) raise,
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
              authModel: AuthModel.classic_sym,
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
                required int Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                int? code;
                final OrcaSpec? res = await tryFetchProject(
                  source: getParam<String>('source')!,
                  dirNotFound: () {
                    raise(HttpStatus.notFound,
                        "Directory not found on specified path '");
                    code = HttpStatus.notFound;
                  },
                  insufficientConfigs: (hasPubspec, hasOrcaspec) {
                    raise(HttpStatus.notFound,
                        "Insufficient config files at target project directory: orcaspec ${hasOrcaspec ? '✅' : '❌'}, pubspec ${hasPubspec ? '✅' : '❌'}.");
                    code = HttpStatus.notFound;
                  },
                );
                if (res != null) {
                  apps.put(res.id, res);
                  keys.put(res.id, secure.generateKey().base64);
                  writeBody(jsonEncode(res.toJson()));
                  code = HttpStatus.ok;
                }
                return code ?? 500;
              },
              requiresAuth: false,
            ),
          ),
          RouteSegment.endpoint(
            routeName: 'delete',
            endpoint: Endpoint(
              authModel: AuthModel.classic_sym,
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
                required int Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final String name = getParam<String>('name')!;
                if (apps.containsKey(name)) {
                  apps.delete(name);
                  keys.delete(name);
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
          RouteSegment.endpoint(
            routeName: 'update',
            endpoint: Endpoint(
              authModel: AuthModel.classic_sym,
              endpointTypes: [EndpointType.post],
              queryParameters: [
                Param.required(
                  'appName',
                  desc: 'The name of the app to update.',
                  cast: (obj) => obj as String,
                ),
                Param.required(
                  'source',
                  desc:
                      'The path of the project root directory from which to pull the new version.',
                  cast: (obj) => obj as String,
                ),
              ],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required int Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final String appName = getParam<String>('appName')!;
                int? code;
                final OrcaSpec? res = await tryFetchProject(
                  source: getParam<String>('source')!,
                  dirNotFound: () {
                    raise(HttpStatus.notFound,
                        "Directory not found on specified path '${getParam('source')}'");
                    code = HttpStatus.notFound;
                  },
                  insufficientConfigs: (hasPubspec, hasOrcaspec) {
                    raise(HttpStatus.notFound,
                        "Insufficient config files at target project directory: orcaspec ${hasOrcaspec ? '✅' : '❌'}, pubspec ${hasPubspec ? '✅' : '❌'}.");
                    code = HttpStatus.notFound;
                  },
                );
                if (res != null) {
                  // Now, update the app in Hive
                  final oldApp = apps.get(appName);
                  if (oldApp == null) {
                    raise(HttpStatus.notFound,
                        "There is no existing app with the name '$appName'.");
                    code = HttpStatus.notFound;
                  } else {
                    await apps.put(oldApp.id, res);
                    writeBody(jsonEncode(res.toJson()));
                    code = HttpStatus.ok;
                  }
                } else {
                  code = HttpStatus.internalServerError;
                }
                return code ?? 500;
              },
              requiresAuth: false,
            ),
          )
        ],
      ),
      RouteSegment.routes(
        routeName: 'engines',
        routes: [
          RouteSegment.endpoint(
            routeName: 'list',
            endpoint: Endpoint(
              authModel: AuthModel.classic_sym,
              endpointTypes: [EndpointType.get],
              queryParameters: [],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required int Function(int, String) raise,
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
              authModel: AuthModel.classic_sym,
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
                required int Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final EngineComponent engine = EngineComponent(
                    version: getParam('version'), path: getParam('source'));
                try {
                  if (engines.containsKey(engine.id)) {
                    return raise(HttpStatus.conflict,
                        'The engine configuration already exists.');
                  } else {
                    // test to see if the engine exists and works
                    final ProcessResult result = await Process.run(
                      engine.path,
                      ['doctor'],
                    );
                    if ((result.stdout as String)
                        .split('\n')
                        .first
                        .startsWith('Doctor summary')) {
                      engines.put(engine.id, engine);
                      return HttpStatus.ok;
                    } else {
                      return raise(HttpStatus.unprocessableEntity,
                          'The provided path does not point to a valid/working Flutter engine.');
                    }
                  }
                } catch (e, st) {
                  print(e);
                  print(st);

                  throw OrcaException(
                      message: e.toString(),
                      exceptionLevel: ExceptionLevel.error,
                      payload: st);
                }
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
              authModel: AuthModel.classic_sym,
              endpointTypes: [EndpointType.get],
              queryParameters: [],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required int Function(int, String) raise,
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
              authModel: AuthModel.classic_sym,
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
                required int Function(int, String) raise,
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
              authModel: AuthModel.classic_sym,
              endpointTypes: [EndpointType.get],
              queryParameters: [],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required int Function(int, String) raise,
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
              authModel: AuthModel.classic_sym,
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
              ],
              bodyParameters: null,
              handleRequest: ({
                required T? Function<T>(String paramName) getParam,
                required int Function(int, String) raise,
                required void Function(String) writeBody,
              }) async {
                final String appName = getParam<String>('appName')!;
                final String engineVersion = getParam<String>('engineVersion')!;
                final OrcaRuntime runtime = OrcaRuntime(
                  orcaSpec: apps.get(appName)!,
                  appName: appName,
                  engineVersion: engineVersion,
                  services: [],
                );
                final Process? proc = await runtime.spawn(
                  encodedKey: keys.get(appName)!,
                );
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
              authModel: AuthModel.classic_sym,
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
                required int Function(int, String) raise,
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
              authModel: AuthModel.classic_sym,
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
                required int Function(int, String) raise,
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
              authModel: AuthModel.classic_sym,
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
                required int Function(int, String) raise,
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
              authModel: AuthModel.classic_sym,
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
                required int Function(int, String) raise,
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

    Hive
      ..registerAdapter(OrcaSpecAdapter())
      ..registerAdapter(EngineComponentAdapter())
      ..registerAdapter(ServiceComponentAdapter())
      ..registerAdapter(ServicePermissionEntryAdapter())
      ..registerAdapter(OrcaRuntimeAdapter());

    apps = await Hive.openBox<OrcaSpec>('apps', path: './');
    services = await Hive.openBox<ServiceComponent>('services', path: './');
    engines = await Hive.openBox<EngineComponent>('engines', path: './');
    runtimes = await Hive.openBox<OrcaRuntime>('runtimes', path: './');

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

  static Future<OrcaSpec?> tryFetchProject({
    required String source,
    required void Function() dirNotFound,
    required void Function(
      bool hasPubspec,
      bool hasOrcaspec,
    ) insufficientConfigs,
  }) async {
    final Directory rootDir = Directory(source);
    final bool exists = await rootDir.exists();
    if (!exists) {
      dirNotFound();
      return null;
    }
    final bool hasPubspec =
        await File(path.join(rootDir.path, 'pubspec.yaml')).exists();
    final bool hasOrcaspec =
        await File(path.join(rootDir.path, 'orcaspec.json')).exists();
    if (hasPubspec && hasOrcaspec) {
      final JSON orcaspec = jsonDecode(
          await File(path.join(rootDir.path, 'orcaspec.json')).readAsString());
      return OrcaSpec.fromJson(orcaspec..putIfAbsent('path', () => source));
    } else {
      insufficientConfigs(hasPubspec, hasOrcaspec);
      return null;
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

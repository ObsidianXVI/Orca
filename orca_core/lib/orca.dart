library orca_core;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:js_util';
import 'dart:math';
import 'package:path/path.dart' as path;

part './orca_configs.dart';
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

  static Future<void> init(OrcaConfigs configs) async {
    orcaConfigs = configs;
    server = await HttpServer.bind(InternetAddress.anyIPv4, 8082);
    print(
        "Server listening on ${Uri(scheme: 'http', host: server.address.host, port: server.port)}");
    server.listen((HttpRequest req) async {
      if (req.uri.pathSegments.isNotEmpty) {
        switch (req.uri.pathSegments[0]) {
          case 'apps':
            if (req.uri.pathSegments.length <= 1) {
              req.response.fromOrcaResult(
                OrcaResult.insufficientPathLengthOfRequest('apps'),
              );
            } else {
              switch (req.uri.pathSegments[1]) {
                case 'list':
                  req.response.fromOrcaResult(appsList());
                  break;
              }
            }

            break;
        }
      } else {
        req.response
          ..headers.set('Access-Control-Allow-Origin', '*')
          ..statusCode = 200;
      }
      req.response.close();
    });
  }

  static OrcaResult appsList() => OrcaResult(
        statusCode: 200,
        payload: [for (final a in orcaConfigs.apps) a.toJson()],
      );

  static Future<OrcaResult> appsAdd(
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
            message: "Directory not found on specified path",
            exceptionLevel: ExceptionLevel.error,
          ),
        );
      }
    }
  }
}

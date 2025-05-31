part of orca_app;

class OrcaAPI {
  static const String apiName = 'orca-api';
  static const String apiHost = 'localhost:8082';
  static final client = http.Client();

  static final orcaApiAppsList = OrcaApiAppsListEndpoint();
  static final orcaApiAppsCreate = OrcaApiAppsCreateEndpoint();
  static final orcaApiAppsDelete = OrcaApiAppsDeleteEndpoint();
  static final orcaApiAppsUpdate = OrcaApiAppsUpdateEndpoint();
  static final orcaApiEnginesList = OrcaApiEnginesListEndpoint();
  static final orcaApiEnginesCreate = OrcaApiEnginesCreateEndpoint();
  static final orcaApiServicesList = OrcaApiServicesListEndpoint();
  static final orcaApiServicesCreate = OrcaApiServicesCreateEndpoint();
  static final orcaApiServicesAdd = OrcaApiServicesAddEndpoint();
  static final orcaApiRuntimesList = OrcaApiRuntimesListEndpoint();
  static final orcaApiRuntimesCreate = OrcaApiRuntimesCreateEndpoint();
  static final orcaApiRuntimesGet = OrcaApiRuntimesGetEndpoint();
  static final orcaApiRuntimesDelete = OrcaApiRuntimesDeleteEndpoint();
  static final orcaApiAppGet = OrcaApiAppGetEndpoint();
  static final orcaApiAppSetup = OrcaApiAppSetupEndpoint();
}

class OrcaApiAppsListEndpoint {
  Future<({List<OrcaSpec> payload})> get() async {
    final res = jsonDecode((await OrcaAPI.client.get(
      Uri.http(
        'localhost:8082',
        'orca-api/apps/list',
        null,
      ),
    ))
        .body);
    return (
      payload: [
        for (final a in res['payload']) OrcaSpec.fromJson(a),
      ]
    );
  }
}

class OrcaApiAppsCreateEndpoint {
  Future<OrcaSpec> post({
    required ({
      String source,
    }) queryParameters,
  }) async {
    final res = jsonDecode((await OrcaAPI.client.post(
      Uri.http(
        'localhost:8082',
        'orca-api/apps/create',
        {
          'source': queryParameters.source,
        },
      ),
    ))
        .body);
    return OrcaSpec.fromJson(res);
  }
}

class OrcaApiAppsDeleteEndpoint {
  Future<http.Response> delete({
    required ({
      String name,
    }) queryParameters,
  }) async {
    return await OrcaAPI.client.post(
      Uri.http(
        'localhost:8082',
        'orca-api/apps/delete',
        {
          'name': queryParameters.name,
        },
      ),
    );
  }
}

class OrcaApiAppsUpdateEndpoint {
  Future<OrcaSpec> post({
    required ({
      String appName,
      String source,
    }) queryParameters,
  }) async {
    final res = jsonDecode((await OrcaAPI.client.post(
      Uri.http(
        'localhost:8082',
        'orca-api/apps/update',
        {
          'appName': queryParameters.appName,
          'source': queryParameters.source,
        },
      ),
    ))
        .body);
    try {
      return OrcaSpec.fromJson(res);
    } on TypeError catch (e, st) {
      throw OrcaException(
        message: 'App update failed.',
        exceptionLevel: ExceptionLevel.error,
        payload: res,
      );
    }
  }
}

class OrcaApiEnginesListEndpoint {
  Future<({List<EngineComponent> payload})> get() async {
    final res = jsonDecode((await OrcaAPI.client.get(
      Uri.http(
        'localhost:8082',
        'orca-api/engines/list',
        null,
      ),
    ))
        .body);
    return (
      payload: [for (final e in res['payload']) EngineComponent.fromJson(e)]
    );
  }
}

class OrcaApiEnginesCreateEndpoint {
  Future<http.Response> post({
    required ({
      String version,
      String source,
    }) queryParameters,
  }) async {
    return await OrcaAPI.client.post(
      Uri.http(
        'localhost:8082',
        'orca-api/engines/create',
        {
          'version': queryParameters.version,
          'source': queryParameters.source,
        },
      ),
    );
  }
}

class OrcaApiServicesListEndpoint {
  Future<({List<ServiceComponent> payload})> get() async {
    final res = jsonDecode((await OrcaAPI.client.get(
      Uri.http(
        'localhost:8082',
        'orca-api/services/list',
        null,
      ),
    ))
        .body);
    return (
      payload: [for (final s in res['payload']) ServiceComponent.fromJson(s)]
    );
  }
}

class OrcaApiServicesCreateEndpoint {
  Future<http.Response> post({
    required ({
      String name,
    }) queryParameters,
  }) async {
    return await OrcaAPI.client.post(
      Uri.http(
        'localhost:8082',
        'orca-api/services/create',
        {
          'name': queryParameters.name,
        },
      ),
    );
  }
}

class OrcaApiServicesAddEndpoint {
  Future<http.Response> post({
    required ({
      String name,
      String version,
      String path,
    }) queryParameters,
  }) async {
    return await OrcaAPI.client.post(
      Uri.http(
        'localhost:8082',
        'orca-api/services/add',
        {
          'name': queryParameters.name,
          'version': queryParameters.version,
          'path': queryParameters.path,
        },
      ),
    );
  }
}

class OrcaApiRuntimesListEndpoint {
  Future<({List<OrcaRuntime> payload})> get() async {
    final res = jsonDecode((await OrcaAPI.client.get(
      Uri.http(
        'localhost:8082',
        'orca-api/runtimes/list',
        null,
      ),
    ))
        .body);
    return (payload: [for (final r in res['payload']) OrcaRuntime.fromJson(r)]);
  }
}

class OrcaApiRuntimesCreateEndpoint {
  Future<http.Response> post({
    required ({
      String appName,
      String engineVersion,
    }) queryParameters,
  }) async {
    return await OrcaAPI.client.post(
      Uri.http(
        'localhost:8082',
        'orca-api/runtimes/create',
        {
          'appName': queryParameters.appName,
          'engineVersion': queryParameters.engineVersion,
        },
      ),
    );
  }
}

class OrcaApiRuntimesGetEndpoint {
  Future<OrcaRuntime> get({
    required ({
      String appName,
    }) queryParameters,
  }) async {
    final res = jsonDecode((await OrcaAPI.client.get(
      Uri.http(
        'localhost:8082',
        'orca-api/runtimes/get',
        {
          'appName': queryParameters.appName,
        },
      ),
    ))
        .body);
    return OrcaRuntime.fromJson(res);
  }
}

class OrcaApiRuntimesDeleteEndpoint {
  Future<http.Response> delete({
    required ({
      String appName,
    }) queryParameters,
  }) async {
    return await OrcaAPI.client.post(
      Uri.http(
        'localhost:8082',
        'orca-api/runtimes/delete',
        {
          'appName': queryParameters.appName,
        },
      ),
    );
  }
}

class OrcaApiAppGetEndpoint {
  Future<OrcaSpec> get({
    required ({
      String appName,
    }) queryParameters,
  }) async {
    return OrcaSpec.fromJson(jsonDecode((await OrcaAPI.client.get(
      Uri.http(
        'localhost:8082',
        'orca-api/app/get',
        {
          'appName': queryParameters.appName,
        },
      ),
    ))
        .body));
  }
}

class OrcaApiAppSetupEndpoint {
  Future<http.Response> post({
    required ({
      String appName,
    }) queryParameters,
  }) async {
    return await OrcaAPI.client.post(
      Uri.http(
        'localhost:8082',
        'orca-api/app/setup',
        {
          'appName': queryParameters.appName,
        },
      ),
    );
  }
}

part of orca_app;

enum OperationType {
  list,
  create,
  delete,
  get,
  setup,
  add;
}

class DaemonBridge {
  static bool serverIsConnected = false;
  static final List<AppComponent> appComponents = [];
  static final List<EngineComponent> engineComponents = [];
  static final List<ServiceComponent> serviceComponents = [];
  static final Client client = Client();

  static Uri endpoint(
    String path,
    OperationType operationType, {
    Map<String, String> params = const {},
  }) =>
      Uri(
        scheme: 'http',
        host: '0.0.0.0',
        port: 8082,
        pathSegments: [path, operationType.name],
        queryParameters: params,
      );

  static Future<bool> checkStatus() async {
    try {
      await client.head(Uri(scheme: 'http', host: '0.0.0.0', port: 8082));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<AppComponent>> getAppComponents() async {
    final Response response =
        await client.get(endpoint('apps', OperationType.list));
    if (response.statusCode != 200) {
      throw OrcaException.fromJson(jsonDecode(response.body));
    }
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));

    return appComponents.updatedTo([
      for (final appComp in (res.payload as List))
        AppComponent.fromJson(appComp)
    ]);
  }

  static Future<List<EngineComponent>> getEngineComponents() async {
    final Response response =
        await client.get(endpoint('engines', OperationType.list));
    if (response.statusCode != 200) {
      throw OrcaException.fromJson(jsonDecode(response.body));
    }
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));

    return engineComponents.updatedTo([
      for (final engineComp in (res.payload as List))
        EngineComponent.fromJson(engineComp)
    ]);
  }

  static Future<List<ServiceComponent>> getServiceComponents() async {
    final Response response =
        await client.get(endpoint('services', OperationType.list));
    if (response.statusCode != 200) {
      throw OrcaException.fromJson(jsonDecode(response.body));
    }
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));

    return serviceComponents.updatedTo([
      for (final svcComp in (res.payload as List))
        ServiceComponent.fromJson(svcComp)
    ]);
  }

  static Future<List<ServiceComponent>> getRuntimes() async {
    final Response response =
        await client.get(endpoint('services', OperationType.list));
    if (response.statusCode != 200) {
      throw OrcaException.fromJson(jsonDecode(response.body));
    }
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));

    return serviceComponents.updatedTo([
      for (final svcComp in (res.payload as List))
        ServiceComponent.fromJson(svcComp)
    ]);
  }

  static Future<void> createRuntime(
      String appName, String engineVersion) async {
    final Response res =
        await client.get(endpoint('app', OperationType.setup, params: {
      'appName': appName,
    }));
    if (res.statusCode != 200) {
      throw OrcaException.fromJson(jsonDecode(res.body));
    }

    final Response response = await client.get(
      endpoint('runtimes', OperationType.create, params: {
        'appName': appName,
        'engineVersion': engineVersion,
      }),
    );
    if (response.statusCode != 200) {
      throw OrcaException.fromJson(jsonDecode(response.body));
    }
  }

  static Future<void> deleteRuntime(String appName) async {
    final Response response = await client.get(
      endpoint('runtimes', OperationType.delete, params: {'appName': appName}),
    );
    if (response.statusCode != 200) {
      throw OrcaException.fromJson(jsonDecode(response.body));
    }
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));
  }

  static Future<OrcaResult> appsCreate(String path) async {
    final Response response = await client.get(
      endpoint('apps', OperationType.create, params: {
        'source': path,
      }),
    );
    if (response.statusCode != 200) {
      throw OrcaException.fromJson(jsonDecode(response.body)['exception']);
    } else {
      return OrcaResult.fromJson(jsonDecode(response.body));
    }
  }

  static Future<AppDetails> appDetails(String appName) async {
    final Response response = await client.get(
      endpoint('app', OperationType.get, params: {'appName': appName}),
    );
    if (response.statusCode != 200) {
      throw OrcaException.fromJson(jsonDecode(response.body)['exception']);
    }
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));
    if ((res.payload as Map<String, dynamic>).isEmpty) {
      return const AppDetails(engine: 'Unspecified', serviceConfigs: [
        {'Unspecified': null}
      ]);
    } else {
      return AppDetails(
        engine: res.payload['engine'],
        serviceConfigs:
            (res.payload['services'] as List).cast<Map<String, dynamic>>(),
      );
    }
  }

  static Future<void> appSetup(String appName) async {
    final Response response = await client.get(
        endpoint('app', OperationType.setup, params: {'appName': appName}));
    if (response.statusCode != 200) {
      throw OrcaException.fromJson(jsonDecode(response.body));
    }
  }
}

class AppDetails {
  final String engine;
  final List<JSON> serviceConfigs;

  const AppDetails({
    required this.engine,
    required this.serviceConfigs,
  });
}

extension ListUtils<T> on List<T> {
  List<T> updatedTo(List<T> newItems) {
    clear();
    addAll(newItems);
    return newItems;
  }
}

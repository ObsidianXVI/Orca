part of orca_app;

enum OperationType {
  list,
  create,
  delete,
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
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));
    if (res.statusCode != 200) throw res.exception!;

    return appComponents.updatedTo([
      for (final appComp in (res.payload as List))
        AppComponent.fromJson(appComp)
    ]);
  }

  static Future<List<EngineComponent>> getEngineComponents() async {
    final Response response =
        await client.get(endpoint('engines', OperationType.list));
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));
    if (res.statusCode != 200) throw res.exception!;

    return engineComponents.updatedTo([
      for (final engineComp in (res.payload as List))
        EngineComponent.fromJson(engineComp)
    ]);
  }

  static Future<List<ServiceComponent>> getServiceComponents() async {
    final Response response =
        await client.get(endpoint('services', OperationType.list));
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));
    if (res.statusCode != 200) throw res.exception!;

    return serviceComponents.updatedTo([
      for (final svcComp in (res.payload as List))
        ServiceComponent.fromJson(svcComp)
    ]);
  }

  static Future<void> createRuntime(
      String appName, String engineVersion) async {
    final Response response = await client.get(
      endpoint('runtimes', OperationType.create, params: {
        'appName': appName,
        'engineVersion': engineVersion,
      }),
    );
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));
    if (res.statusCode != 200) throw res.exception!;
  }

  static Future<void> deleteRuntime(String appName) async {
    final Response response = await client.get(
      endpoint('runtimes', OperationType.delete, params: {'appName': appName}),
    );
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));
    if (res.statusCode != 200) throw res.exception!;
  }
}

extension ListUtils<T> on List<T> {
  List<T> updatedTo(List<T> newItems) {
    clear();
    addAll(newItems);
    return newItems;
  }
}

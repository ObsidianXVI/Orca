part of orca_app;

class DaemonBridge {
  static bool serverIsConnected = false;
  static final List<AppComponent> appComponents = [];
  static final Client client = Client();

  static Uri endpoint(String path) =>
      Uri(scheme: 'http', host: '0.0.0.0', port: 8082, pathSegments: [path]);

  static Future<bool> checkStatus() async {
    try {
      await client.head(Uri(scheme: 'http', host: '0.0.0.0', port: 8082));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<AppComponent>> getAppComponents() async {
    final Response response = await client.get(endpoint('apps'));
    final OrcaResult res = OrcaResult.fromJson(jsonDecode(response.body));
    // dev arch more to handle errors as well
    return appComponents.updatedTo([
      for (final appComp in (res.payload as List))
        AppComponent.fromJson(appComp)
    ]);
  }
}

extension ListUtils<T> on List<T> {
  List<T> updatedTo(List<T> newItems) {
    clear();
    addAll(newItems);
    return newItems;
  }
}

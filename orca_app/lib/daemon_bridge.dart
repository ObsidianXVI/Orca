part of orca_app;

class DaemonBridge {
  static final List<AppComponent> appComponents = [];
  static final Client client = Client();

  static Uri endpoint(String path) =>
      Uri(scheme: 'http', host: '0.0.0.0', port: 8082, pathSegments: [path]);

  static Future<List<AppComponent>> getAppComponents() async {
    final Response res = await client.get(endpoint('apps'));
    return appComponents
      ..clear()
      ..addAll([
        for (final appComp in (jsonDecode(res.body)['payload'] as List))
          AppComponent.fromJson(appComp)
      ]);
  }
}

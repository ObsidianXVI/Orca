part of orca_app;

mixin DaemonBridgeAccess<T extends StatefulWidget> on State<T> {
  final Future<bool> _checkOrcaDaemonStatusFuture = DaemonBridge.checkStatus();

  Widget usesDaemonBridge<R>({
    required String routeName,
    required Future<R> daemonCall,
    required Widget Function(BuildContext, R) builder,
  }) {
    return FutureBuilder(
      future: _checkOrcaDaemonStatusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            return FutureBuilder(
              future: daemonCall,
              builder: (context2, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return builder(context2, snapshot.data!);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          } else {
            return connectionErrorWidget(routeName);
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget connectionErrorWidget(String routeName) {
    return Center(
      child: Container(
        width: 400,
        height: 300,
        child: Column(
          children: [
            const Text(
                "Daemon is not connected. Ensure the server has been started."),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, routeName);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

part of orca_app;

class AppsView extends StatefulWidget {
  const AppsView({super.key});

  @override
  State<StatefulWidget> createState() => AppsViewState();
}

class AppsViewState extends State<AppsView> with DaemonBridgeAccess {
  @override
  Widget build(BuildContext context) {
    return usesDaemonBridge(
      routeName: '/apps',
      daemonCall: DaemonBridge.getAppComponents(),
      builder: (context, appComponents) {
        return Text("${appComponents.length} apps found");
      },
    );
  }
}

part of orca_app;

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<StatefulWidget> createState() => DashboardViewState();
}

class DashboardViewState extends State<DashboardView> with DaemonBridgeAccess {
  AppComponent? currentAppComponent;

  @override
  Widget build(BuildContext context) {
    return usesDaemonBridge(
      routeName: '/',
      daemonCall: DaemonBridge.getAppComponents(),
      builder: (context, appComponents) {
        return Scaffold(
          appBar: AppBar(
            title: DropdownMenu<AppComponent>(
              initialSelection: appComponents.firstOrNull,
              onSelected: (value) =>
                  setState(() => currentAppComponent = value),
              dropdownMenuEntries:
                  List<DropdownMenuEntry<AppComponent>>.generate(
                appComponents.length,
                (i) => DropdownMenuEntry<AppComponent>(
                  value: appComponents[i],
                  label: appComponents[i].appName,
                ),
              ),
            ),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  child: Text('Orca'),
                ),
                ListTile(
                  title: const Text('Apps'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/apps');
                  },
                ),
                ListTile(
                  title: const Text('Engines'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/engines');
                  },
                ),
                ListTile(
                  title: const Text('Services'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/services');
                  },
                ),
                ListTile(
                  title: const Text('Runtimes'),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Environments'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          body: TextButton(
            child: const Text('Start running'),
            onPressed: () {
              // dialog to configure a runtime, where they select engine and services
            },
          ),
        );
      },
    );
  }
}

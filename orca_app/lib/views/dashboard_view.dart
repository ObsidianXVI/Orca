part of orca_app;

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<StatefulWidget> createState() => DashboardViewState();
}

class DashboardViewState extends State<DashboardView> with DaemonBridgeAccess {
  AppComponent? currentAppComponent;
  bool hasRuntime = false;

  @override
  void initState() {
    DaemonBridge.getAppComponents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return usesDaemonBridge(
      routeName: '/',
      daemonCall: DaemonBridge.getAppComponents(),
      builder: (context, appComponents) {
        currentAppComponent ??= appComponents.firstOrNull;
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
          body: Column(
            children: [
              hasRuntime
                  ? TextButton(
                      child: const Text('Stop running'),
                      onPressed: () async {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Stopping runtime..."),
                            ),
                          );
                        }
                        await DaemonBridge.deleteRuntime(
                            currentAppComponent!.appName);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Runtime deleted successfully!"),
                            ),
                          );
                        }
                        setState(() {
                          hasRuntime = false;
                        });
                      },
                    )
                  : TextButton(
                      child: const Text('Start running'),
                      onPressed: () async {
                        final Map<String, String>? results =
                            await showDialog<Map<String, String>>(
                          context: context,
                          builder: (_) => Container(
                            child: RuntimeConfigurationForm(
                              header:
                                  "Create a runtime for \"${currentAppComponent!.appName}\"",
                              appName: currentAppComponent!.appName,
                            ),
                          ),
                        );
                        if (results != null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Creating runtime..."),
                              ),
                            );
                          }
                          try {
                            await DaemonBridge.createRuntime(
                                results['appName']!, results['engineVersion']!);
                            setState(() {
                              hasRuntime = true;
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Runtime created successfully!"),
                                ),
                              );
                            }
                          } on OrcaException catch (e) {
                            if (mounted) {
                              showDialog(
                                barrierColor: Colors.black.withOpacity(0.4),
                                context: context,
                                builder: (_) => Center(
                                  child: Container(
                                    width: 800,
                                    height: 800,
                                    color: OrcaColorSchme.darkPurple,
                                    child: Padding(
                                      padding: const EdgeInsets.all(40),
                                      child: Column(
                                        children: [
                                          const Text(
                                              "Runtime creation failed:"),
                                          const SizedBox(height: 10),
                                          Text(e.message),
                                          const SizedBox(height: 10),
                                          Text(e.payload),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Runtime discarded"),
                              ),
                            );
                          }
                        }
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}

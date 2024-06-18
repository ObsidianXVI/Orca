part of orca_app;

class RuntimesView extends StatefulWidget {
  const RuntimesView({super.key});

  @override
  State<StatefulWidget> createState() => RuntimesViewState();
}

class RuntimesViewState extends State<RuntimesView> with DaemonBridgeAccess {
  @override
  Widget build(BuildContext context) {
    return usesDaemonBridge(
        routeName: '/runtimes',
        daemonCall: DaemonBridge.getRuntimes(),
        builder: (context, runtimes) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Runtimes'),
              actions: [
                TextButton(
                  child: const Text('Start running'),
                  onPressed: () async {
                    final appComponents = await DaemonBridge.getAppComponents();
                    if (!mounted) return;
                    final Map<String, String>? results =
                        await showDialog<Map<String, String>>(
                      context: context,
                      builder: (_) => SizedBox(
                        child: RuntimeConfigurationForm(
                          header: "Configure runtime details",
                          appNames: [
                            for (final ac in appComponents) ac.appName
                          ],
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
                        setState(() {});
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Runtime created successfully!"),
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
                                      const Text("Runtime creation failed:"),
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
                )
              ],
            ),
            body: runtimes.isNotEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 500,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: runtimes.length,
                    itemBuilder: (_, i) => RuntimeWindow(
                      runtime: runtimes[i],
                      refreshGridView: setState,
                    ),
                  )
                : null,
          );
        });
  }
}

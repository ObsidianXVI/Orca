part of orca_app;

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<StatefulWidget> createState() => DashboardViewState();
}

class DashboardViewState extends State<DashboardView> {
  AppComponent? currentAppComponent;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: OrcaApiAppsListEndpoint().get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          currentAppComponent ??= snapshot.requireData.payload.firstOrNull;
          return Scaffold(
            appBar: AppBar(
              title: DropdownButton<AppComponent>(
                value: currentAppComponent ??
                    snapshot.requireData.payload.firstOrNull,
                onChanged: (value) {
                  setState(() {
                    currentAppComponent = value;
                  });
                },
                items: List<DropdownMenuItem<AppComponent>>.generate(
                  snapshot.requireData.payload.length,
                  (i) => DropdownMenuItem<AppComponent>(
                    value: snapshot.requireData.payload[i],
                    child: Text(snapshot.requireData.payload[i].appName),
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
                    onTap: () {
                      Navigator.of(context).pushNamed('/runtimes');
                    },
                  ),
                  ListTile(
                    title: const Text('Environments'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: OrcaApiRuntimesListEndpoint().get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.requireData.payload.isNotEmpty
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
                                  await OrcaApiRuntimesDeleteEndpoint().delete(
                                      queryParameters: (
                                        appName: currentAppComponent!.appName
                                      ));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Runtime deleted successfully!"),
                                      ),
                                    );
                                  }
                                  setState(() {});
                                },
                              )
                            : TextButton(
                                child: const Text('Start running'),
                                onPressed: () async {
                                  final Map<String, String>? results =
                                      await showDialog<Map<String, String>>(
                                    context: context,
                                    builder: (_) => SizedBox(
                                      child: RuntimeConfigurationForm(
                                        header:
                                            "Create a runtime for \"${currentAppComponent!.appName}\"",
                                        appNames: [
                                          currentAppComponent!.appName
                                        ],
                                      ),
                                    ),
                                  );
                                  if (results != null) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text("Creating runtime..."),
                                        ),
                                      );
                                    }
                                    try {
                                      final res =
                                          await OrcaApiRuntimesCreateEndpoint()
                                              .post(queryParameters: (
                                        appName: results['appName']!,
                                        engineVersion:
                                            results['engineVersion']!,
                                      ));
                                      setState(() {});
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(res.statusCode == 201
                                                ? "Runtime created successfully!"
                                                : "Runtime creation failed."),
                                          ),
                                        );
                                      }
                                    } on OrcaException catch (e) {
                                      if (context.mounted) {
                                        showDialog(
                                          barrierColor:
                                              Colors.black.withOpacity(0.4),
                                          context: context,
                                          builder: (_) => Center(
                                            child: Container(
                                              width: 800,
                                              height: 800,
                                              color: OrcaColorSchme.darkPurple,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(40),
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text("Runtime discarded"),
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                      } else {
                        return const SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  if (currentAppComponent != null)
                    FutureBuilder(
                      future: OrcaApiAppGetEndpoint().get(queryParameters: (
                        appName: currentAppComponent!.appName
                      )),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState !=
                            ConnectionState.waiting) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                'Details',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text('Path: ${currentAppComponent?.path}'),
                              const SizedBox(height: 5),
                              Text('Engine: ${snapshot.data?.engine}'),
                              const SizedBox(height: 5),
                              Text(
                                  'Services: ${snapshot.data?.services.map((c) => c.name).join(", ")}'),
                              const SizedBox(height: 10),
                            ],
                          );
                        } else {
                          return const SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

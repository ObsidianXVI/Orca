part of orca_app;

class AppsView extends StatefulWidget {
  const AppsView({super.key});

  @override
  State<StatefulWidget> createState() => AppsViewState();
}

class AppsViewState extends State<AppsView> with DaemonBridgeAccess {
  final TextEditingController addAppTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return usesDaemonBridge(
      routeName: '/apps',
      daemonCall: DaemonBridge.getAppComponents(),
      builder: (context, appComponents) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Apps'),
            actions: [
              TextButton(
                onPressed: () {
                  showDialog(
                      context: context, builder: (ctx) => addAppDialog(ctx));
                },
                child: const Text('Add app'),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Flexible(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: List<Widget>.generate(
                      appComponents.length,
                      (i) => Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 400,
                          height: 100,
                          color: Theme.of(context).cardTheme.surfaceTintColor,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(appComponents[i].appName),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  SimpleDialog addAppDialog(BuildContext context) {
    return SimpleDialog(
      title: const Text('Add App'),
      children: [
        TextField(
          controller: addAppTextController,
          decoration: const InputDecoration(
            labelText: 'Path to root directory of project, or Git repo URL',
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () async {
            // communicate with Daemon to verify path
            final bool valid = true;
            if (valid) {
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Save',
          ),
        ),
      ],
    );
  }
}

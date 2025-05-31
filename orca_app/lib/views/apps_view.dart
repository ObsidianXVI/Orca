part of orca_app;

class AppsView extends StatefulWidget {
  const AppsView({super.key});

  @override
  State<StatefulWidget> createState() => AppsViewState();
}

class AppsViewState extends State<AppsView> {
  final TextEditingController addAppTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: OrcaAPI.orcaApiAppsList.get(),
      builder: (context, snapshot) {
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
                      snapshot.requireData.payload.length,
                      (i) => Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 400,
                          height: 100,
                          color: Theme.of(context).cardTheme.surfaceTintColor,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Text(
                                    snapshot.requireData.payload[i].appName),
                              ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                            '/apps/${snapshot.requireData.payload[i].appName.urlSafeSlug}');
                                      },
                                      icon: const Icon(Icons.settings),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
      title: const Text(
        'Add App',
        style: TextStyle(color: OrcaColorSchme.lightPink),
      ),
      contentPadding: const EdgeInsets.all(20),
      children: [
        const SizedBox(width: 600),
        TextField(
          controller: addAppTextController,
          cursorColor: OrcaColorSchme.almostWhite,
          decoration: const InputDecoration(
            labelText: 'Path to root directory of project, or Git repo URL',
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () async {
            try {
              await OrcaApiAppsCreateEndpoint()
                  .post(queryParameters: (source: addAppTextController.text));

              if (mounted) Navigator.of(context).pop();
            } on OrcaException catch (e) {
              if (mounted) {
                await showDialog(
                  context: context,
                  builder: (ctx) => Center(
                    child: Container(
                      width: 500,
                      height: 500,
                      color: Colors.black,
                      child: Text("${e.message}\n\n${e.payload}"),
                    ),
                  ),
                );
              }
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

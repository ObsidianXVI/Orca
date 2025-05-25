part of orca_app;

class EnginesView extends StatefulWidget {
  const EnginesView({super.key});

  @override
  State<StatefulWidget> createState() => EnginesViewState();
}

class EnginesViewState extends State<EnginesView> {
  final TextEditingController addAppTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: OrcaApiEnginesListEndpoint().get(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Engines'),
            actions: [
              TextButton(
                onPressed: () async {
                  final Map<String, String>? res = await showDialog(
                      context: context, builder: (ctx) => addEngineDialog(ctx));
                  if (context.mounted) {
                    if (res != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Verifying given engine path..."),
                        ),
                      );
                      // call API
                      final apiRes = await OrcaAPI.orcaApiEnginesCreate.post(
                          queryParameters: (
                            source: res['enginePath']!,
                            version: '*'
                          ));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: apiRes.statusCode == HttpStatus.ok
                                ? const Text('Engine added successfully!')
                                : const Text('Engine registration failed!')));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Action aborted"),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Add engine'),
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
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child:
                                  Text(snapshot.requireData.payload[i].version),
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

  SimpleDialog addEngineDialog(BuildContext context) {
    final TextEditingController enginePathController = TextEditingController();
    return SimpleDialog(
      title: const Text('Add Engine'),
      children: [
        TextField(
          controller: enginePathController,
          decoration: const InputDecoration(
            labelText: 'Path to directory of Flutter SDK',
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () async {
            Navigator.of(context)
                .pop({'enginePath': enginePathController.text});
          },
          child: const Text(
            'Save',
          ),
        ),
      ],
    );
  }
}

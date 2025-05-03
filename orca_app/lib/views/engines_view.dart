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
                onPressed: () {
                  showDialog(
                      context: context, builder: (ctx) => addAppDialog(ctx));
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

  SimpleDialog addAppDialog(BuildContext context) {
    return SimpleDialog(
      title: const Text('Add Engine'),
      children: [
        TextField(
          controller: addAppTextController,
          decoration: const InputDecoration(
            labelText: 'Path to directory of Flutter SDK',
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () async {
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

part of orca_app;

class ServicesView extends StatefulWidget {
  const ServicesView({super.key});

  @override
  State<StatefulWidget> createState() => ServicesViewState();
}

class ServicesViewState extends State<ServicesView> {
  final TextEditingController addAppTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: OrcaApiServicesListEndpoint().get(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Services'),
            actions: [
              TextButton(
                onPressed: () {
                  showDialog(
                      context: context, builder: (ctx) => addAppDialog(ctx));
                },
                child: const Text('Add service'),
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
                              child: Text(snapshot.requireData.payload[i].name),
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
      title: const Text('Add Service'),
      children: [
        TextField(
          controller: addAppTextController,
          decoration: const InputDecoration(
            labelText: 'Path to service root directory',
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

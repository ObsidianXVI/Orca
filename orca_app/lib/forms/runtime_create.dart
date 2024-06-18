part of orca_app;

class RuntimeConfigurationForm extends StatefulWidget {
  final List<String> appNames;
  final String header;

  const RuntimeConfigurationForm({
    required this.header,
    required this.appNames,
    super.key,
  });
  @override
  State<StatefulWidget> createState() => RuntimeConfigurationFormState();
}

class RuntimeConfigurationFormState extends State<RuntimeConfigurationForm> {
  late String engineVersion;
  String? chosenApp;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                width: double.infinity,
                height: 60,
                color: OrcaColorSchme.darkPurple,
                child: Text(widget.header),
              ),
            ),
            Positioned(
              top: 0,
              left: 40,
              right: 40,
              bottom: 0,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  DropdownButtonFormField<String>(
                    style: const TextStyle(color: OrcaColorSchme.almostWhite),
                    items: [
                      for (final appName in widget.appNames)
                        DropdownMenuItem(
                          value: appName,
                          child: Text(appName),
                        )
                    ],
                    onChanged: (String? app) =>
                        app != null ? chosenApp = app : null,
                  ),
                  FutureBuilder(
                    future: DaemonBridge.getEngineComponents(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return DropdownButtonFormField<String>(
                          style: const TextStyle(
                              color: OrcaColorSchme.almostWhite),
                          items: [
                            for (EngineComponent ec in snapshot.data!)
                              DropdownMenuItem(
                                value: ec.version,
                                child: Wrap(
                                  direction: Axis.vertical,
                                  children: [
                                    Text(ec.version),
                                    const SizedBox(height: 5),
                                    Text(ec.path),
                                  ],
                                ),
                              )
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              engineVersion = newValue;
                            }
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  const SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, null);
                        },
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          if (chosenApp != null) {
                            Navigator.pop(context, {
                              'appName': chosenApp!,
                              'engineVersion': engineVersion,
                            });
                          } else {
                            throw const OrcaException(
                              message: "App Name cannot be null",
                              exceptionLevel: ExceptionLevel.error,
                            );
                          }
                        },
                        child: const Text("Create"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

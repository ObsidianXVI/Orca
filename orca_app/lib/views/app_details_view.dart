part of orca_app;

class AppDetailsView extends StatelessWidget {
  final OrcaSpec orcaSpec;

  const AppDetailsView({
    required this.orcaSpec,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(orcaSpec.appName),
        actions: [
          TextButton(
            onPressed: () async {
              final String? path =
                  await showDialog(context: context, builder: updateAppDialog);
              if (path != null && path.isNotEmpty) {
                try {
                  await OrcaAPI.orcaApiAppsUpdate.post(
                    queryParameters: (
                      appName: orcaSpec.appName,
                      source: path,
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App updated successfully.'),
                      ),
                    );
                  }
                } on OrcaException catch (e) {
                  if (context.mounted) {
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
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('App update aborted.'),
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () async {
              await OrcaAPI.orcaApiAppsDelete
                  .delete(queryParameters: (name: orcaSpec.appName));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  SimpleDialog updateAppDialog(BuildContext context) {
    final TextEditingController updateAppTextController =
        TextEditingController();
    return SimpleDialog(
      title: const Text(
        'Update App',
        style: TextStyle(color: OrcaColorSchme.lightPink),
      ),
      contentPadding: const EdgeInsets.all(20),
      children: [
        const SizedBox(width: 600),
        TextField(
          controller: updateAppTextController,
          cursorColor: OrcaColorSchme.almostWhite,
          decoration: const InputDecoration(
            labelText:
                'Path to the root directory which contains the updated orcaspec and/or code artifacts.',
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () async {
            try {
              if (context.mounted) {
                Navigator.of(context).pop(updateAppTextController.text);
              }
            } on OrcaException catch (e) {
              if (context.mounted) {
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
            'Update',
          ),
        ),
      ],
    );
  }
}

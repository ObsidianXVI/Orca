part of orca_app;

class RuntimeWindow extends StatefulWidget {
  final OrcaRuntime runtime;
  final void Function(VoidCallback) refreshGridView;

  const RuntimeWindow({
    required this.runtime,
    required this.refreshGridView,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => RuntimeWindowState();
}

class RuntimeWindowState extends State<RuntimeWindow> {
  final ScrollController scrollController = ScrollController();
  final List<String> logs = [];
  Timer? liveLoggingFetchTimer;

  void activateLiveMode() {
    liveLoggingFetchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  void deactivateLiveMode() {
    liveLoggingFetchTimer?.cancel();
    liveLoggingFetchTimer = null;
  }

  @override
  void initState() {
    logs.addAll(widget.runtime.logs);

    activateLiveMode();
    Future.delayed(const Duration(seconds: 3), () {
      if (liveLoggingFetchTimer != null) {
        setState(() {
          deactivateLiveMode();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(
      header: GridTileBar(
        backgroundColor: OrcaColorSchme.darkPurple.withOpacity(0.6),
        title: Text(widget.runtime.appName),
        trailing: Row(
          children: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  liveLoggingFetchTimer == null
                      ? Colors.transparent
                      : OrcaColorSchme.lightPink.withOpacity(0.4),
                ),
              ),
              onPressed: () {
                if (liveLoggingFetchTimer == null) {
                  activateLiveMode();
                } else {
                  deactivateLiveMode();
                  setState(() {});
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.sensors),
                  SizedBox(width: 10),
                  Text('Live'),
                ],
              ),
            ),
            DropdownMenu(
              dropdownMenuEntries: [],
            ),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 500,
        decoration: BoxDecoration(
          color: OrcaColorSchme.darkPurple.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              bottom: 50,
              child: FutureBuilder<List<String>>(
                initialData: logs,
                future: () async {
                  if (liveLoggingFetchTimer == null) {
                    return logs;
                  } else {
                    return (logs
                      ..clear()
                      ..addAll((await DaemonBridge.getRuntime(
                              widget.runtime.appName))
                          .logs));
                  }
                }(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.waiting) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      scrollController.jumpTo(
                        scrollController.position.maxScrollExtent,
                      );
                    });
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: SelectionArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final lg in logs) Text(lg),
                          ],
                        ),
                      ),
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
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: TextButton(
                onPressed: () async {
                  await DaemonBridge.deleteRuntime(widget.runtime.appName);
                  widget.refreshGridView(() {});
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Runtime deleted successfully!"),
                      ),
                    );
                  }
                },
                child: const Text('Stop runtime'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

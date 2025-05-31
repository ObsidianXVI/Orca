part of orca_app;

extension StrinUtils on String {
  String get urlSafeSlug =>
      toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\s]+'), '');
}

extension SnapshotUtils on AsyncSnapshot {
  Widget standardHandler(Widget Function() builder) {
    switch (connectionState) {
      case ConnectionState.none:
      case ConnectionState.done:
        if (hasError) {
          if (error is http.ClientException) {
            return const Material(
              child: Center(
                child: SizedBox.expand(
                  child: Center(
                    child: Text(
                        'Failed to fetch from server. Ensure Orca server is running.'),
                  ),
                ),
              ),
            );
          } else {
            return builder();
          }
        } else {
          return builder();
        }
      case ConnectionState.waiting:
      case ConnectionState.active:
        return const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}

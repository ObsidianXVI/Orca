part of orca_app;

class OrcaButtonStyle {
  static TextButtonThemeData textButtonStyle = TextButtonThemeData(
    style: ButtonStyle(
      animationDuration: const Duration(milliseconds: 300),
      splashFactory: InkSplash.splashFactory,
      tapTargetSize: MaterialTapTargetSize.padded,
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      backgroundColor: MaterialStateColor.resolveWith(
        (states) {
          if (states.contains(MaterialState.pressed)) {
            return OrcaColorSchme.darkPurple.withOpacity(0.6);
          } else if (states.contains(MaterialState.hovered)) {
            return OrcaColorSchme.darkPurple.withOpacity(0.4);
          } else {
            return OrcaColorSchme.darkPurple;
          }
        },
      ),
      foregroundColor: MaterialStateColor.resolveWith(
        (states) {
          if (states.contains(MaterialState.disabled)) {
            return OrcaColorSchme.lightPurple.withOpacity(0.3);
          } else if (states.contains(MaterialState.hovered)) {
            return OrcaColorSchme.lightPink;
          } else {
            return OrcaColorSchme.lightPink.withOpacity(0.6);
          }
        },
      ),
    ),
  );
}

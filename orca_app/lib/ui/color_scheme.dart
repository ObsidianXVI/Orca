part of orca_app;

class OrcaColorSchme {
  static const Color darkPurple = Color(0xff22223B);
  static const Color lightPurple = Color(0xff4A4E69);
  static const Color lightPink = Color(0xff9A8C98);
  static const Color almostWhite = Color(0xffF2E9E4);

  static ColorScheme colorSchemeDark = ColorScheme(
    primary: lightPurple,
    secondary: lightPink,
    background: lightPurple,
    onBackground: lightPink,
    onPrimary: lightPink,
    onSecondary: lightPink,
    surface: darkPurple,
    onSurface: almostWhite,
    error: const Color(0xffd62828).withOpacity(0.2),
    onError: almostWhite,
    brightness: Brightness.dark,
  );
}

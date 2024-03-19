import 'package:flutter/material.dart';

TextStyle getTextStyle(double fontSize,
    [Color textColor = Colors.black,
    FontStyle fontStyle = FontStyle.normal,
    FontWeight fontWeight = FontWeight.w300]) {
  return TextStyle(
    fontFamily: 'Roboto',
    fontStyle: FontStyle.normal,
    fontWeight: fontWeight,
    fontSize: fontSize,
    color: textColor,
  );
}

TextTheme getTextTheme(Color textColor, Color labelColor) {
  return TextTheme(
      titleLarge: TextStyle(
        fontFamily: 'Roboto',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.8,
        height: 1.3,
        fontSize: 30,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Roboto',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        height: 1.3,
        fontSize: 25,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Roboto',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.3,
        height: 1.3,
        fontSize: 22,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Roboto',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.3,
        height: 1.3,
        fontSize: 18,
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Roboto',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w300,
        height: 1.3,
        fontSize: 18,
        color: labelColor,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Roboto',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w300,
        height: 1.3,
        fontSize: 16,
        color: labelColor,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Roboto',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w300,
        height: 1.3,
        fontSize: 14,
        color: labelColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w300,
        height: 1.3,
        fontSize: 16,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w300,
        height: 1.3,
        fontSize: 14,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Roboto',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w300,
        height: 1.3,
        fontSize: 12,
        color: textColor,
      ));
}

ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    shadowColor: Colors.grey.withOpacity(0.5),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color.fromARGB(255, 16, 149, 193),
      onPrimary: Colors.white,
      secondary: Color.fromARGB(255, 16, 149, 193),
      onSecondary: Colors.white,
      tertiary: Color(0xFF5B5B5B),
      error: Colors.red,
      onError: Colors.white,
      background: Colors.white,
      onBackground: Color.fromARGB(255, 55, 55, 55),
      surface: Color.fromARGB(255, 226, 226, 226),
      onSurface: Color.fromARGB(255, 55, 55, 55),
      surfaceVariant: Color.fromARGB(255, 166, 166, 166),
      onSurfaceVariant: Color.fromARGB(255, 55, 55, 55),
    ),
    textTheme:
        getTextTheme(const Color.fromARGB(255, 55, 55, 55), Colors.white));

ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    shadowColor: const Color.fromARGB(255, 44, 44, 44).withOpacity(0.5),
    scaffoldBackgroundColor: const Color.fromARGB(255, 17, 25, 31),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color.fromARGB(255, 16, 149, 193),
      onPrimary: Colors.white,
      secondary: Color.fromARGB(255, 16, 149, 193),
      onSecondary: Colors.white,
      tertiary: Color(0xFF5B5B5B),
      error: Colors.red,
      onError: Colors.white,
      background: Color.fromARGB(255, 17, 25, 31),
      onBackground: Colors.white,
      surface: Color.fromARGB(255, 41, 48, 54),
      onSurface: Colors.white,
      surfaceVariant: Color.fromARGB(255, 112, 112, 112),
      onSurfaceVariant: Colors.white,
    ),
    textTheme: getTextTheme(Colors.white, Colors.white));

bool useDarkTheme = true;

getSystemTheme() {
  if (useDarkTheme) {
    return darkTheme;
  } else {
    return lightTheme;
  }
}

Map<String, List> themeRegistry = {
  "light": ["Hell", lightTheme],
  "dark": ["Dunkel", darkTheme],
};

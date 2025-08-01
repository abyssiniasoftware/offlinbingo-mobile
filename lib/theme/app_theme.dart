import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
    useMaterial3: true,
    brightness: Brightness.light,
  );


  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.black,
    fontFamily: 'Roboto',
    useMaterial3: true,
    brightness: Brightness.dark,
  );
}

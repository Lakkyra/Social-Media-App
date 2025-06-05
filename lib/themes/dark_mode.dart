import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    //very dark- appbar and drawer
    surface: Color.fromARGB(255, 9, 9, 9),
    //slightly light
    primary: Color.fromARGB(255, 105, 105, 105),
    //dark
    secondary: Color.fromARGB(255, 20, 20, 20),
    //slightly dark
    tertiary: Color.fromARGB(255, 30, 30, 30),
    //very light
    inversePrimary: Color.fromARGB(255, 199, 199, 199),
  ),
  scaffoldBackgroundColor: Color.fromARGB(255, 9, 9, 9),
);

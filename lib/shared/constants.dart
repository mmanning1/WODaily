import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0)
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2.0)
  )
);

const workoutFormDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(color: Colors.black),
    contentPadding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
    border: OutlineInputBorder(
      //borderRadius: const BorderRadius.all(Radius.circular(10))
    )
);

ThemeData mainThemeData = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey.shade200,
    cardColor: Colors.white,
    primaryColor: Colors.blue.shade900,

    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(primary: Colors.blue.shade900),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.red.shade900
    ),

    appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue.shade900
    )
);

const List<String> wodTypes = ['Select One','AMRAP','EMOM','Reps','For time','For weight','Chipper','Ladder','Tabata'];
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Màu chủ đạo
const Color primaryBlue = Color(0xFF1E88E5);
const Color primaryDarkBlue = Color(0xFF1565C0);
const Color lightBlue = Color(0xFF42A5F5);
const Color skyBlue = Color(0xFF4FC3F7);

/// Nền
const Color backgroundLight = Color(0xFFF5F9FF);
const Color backgroundDark = Color(0xFF0D0D0D);

/// Card
const Color cardLight = Colors.white;
const Color cardDark = Color(0xFF1E1E1E);

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: primaryBlue,
  scaffoldBackgroundColor: backgroundLight,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: primaryBlue,
    onPrimary: Colors.white,
    secondary: skyBlue,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: backgroundLight,
    onBackground: primaryDarkBlue,
    surface: cardLight,
    onSurface: Colors.black87,
  ),
  textTheme: GoogleFonts.nunitoTextTheme().apply(
    bodyColor: Colors.black87,
    displayColor: Colors.black87,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: GoogleFonts.nunito(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    color: cardLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: lightBlue,
  scaffoldBackgroundColor: backgroundDark,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: lightBlue,
    onPrimary: Colors.black,
    secondary: skyBlue,
    onSecondary: Colors.black,
    error: Colors.redAccent,
    onError: Colors.black,
    background: backgroundDark,
    onBackground: Colors.white,
    surface: cardDark,
    onSurface: Colors.white,
  ),
  textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: primaryDarkBlue,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: GoogleFonts.nunito(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    color: cardDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lightBlue,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);

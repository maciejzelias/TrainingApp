import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData;

  setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
  }
}

class Themes {
  static TextTheme whiteText = TextTheme(
      bodyText1: GoogleFonts.publicSans(
          fontSize: 14, color: Colors.white54, fontWeight: FontWeight.normal),
      headline1: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 50.0,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = Colors.red),
      headline2: TextStyle(fontSize: 15, color: Colors.white));

  static TextTheme blackText = TextTheme(
      bodyText1: GoogleFonts.publicSans(
          fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal),
      headline2: TextStyle(fontSize: 15, color: Colors.black));

  static ThemeData energyTheme() {
    return ThemeData(
        brightness: Brightness.light,
        primaryColor: Color.fromARGB(255, 223, 39, 26),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color.fromARGB(255, 83, 178, 255),
          tertiary: Color.fromARGB(255, 0, 30, 54),
        ),
        shadowColor: Colors.black54,
        cardColor: Colors.white54,
        hintColor: Color.fromARGB(82, 70, 70, 70),
        secondaryHeaderColor: Colors.white,
        textTheme: whiteText,
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black));
  }

  static ThemeData yellowBlack() {
    return ThemeData(
        // inputDecorationTheme: InputDecorationTheme(
        //   focusedErrorBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.all(Radius.circular(60)),
        //       gapPadding: 5,
        //       borderSide: BorderSide(color: Colors.white, width: 2)),
        //   errorStyle: TextStyle(color: Colors.white),
        //   fillColor: Colors.black,
        //   filled: true,
        //   labelStyle: TextStyle(
        //     color: Colors.white,
        //   ),
        //   floatingLabelStyle: TextStyle(
        //       color: Colors.white, backgroundColor: Colors.transparent),
        //   errorBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.all(Radius.circular(60)),
        //       borderSide: BorderSide(color: Colors.white)),
        //   focusedBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.all(Radius.circular(60)),
        //       gapPadding: 5,
        //       borderSide: BorderSide(color: Colors.white, width: 2)),
        //   enabledBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.all(Radius.circular(60)),
        //       borderSide: BorderSide(width: 2, color: Colors.white)),
        //   border: UnderlineInputBorder(
        //     borderSide: BorderSide.none,
        //   ),
        // ),
        // focusColor: Colors.black,
        brightness: Brightness.light,
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color.fromARGB(255, 248, 226, 31),
          tertiary: Colors.black38,
        ),
        shadowColor: Colors.white54,
        cardColor: Colors.transparent,
        secondaryHeaderColor: Colors.black,
        textTheme: whiteText,
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black));
  }
}

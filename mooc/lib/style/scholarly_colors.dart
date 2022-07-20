import 'package:flutter/material.dart'; // Flutter

//const COLOR_MAIN = const Color(0xFF006EB4);
const scholarlyRed = Color(0xFFD41C3A);
const scholarlyRedLight = Color(0xFFfad1d8);
const scholarlyRedBackground = Color(0xFFFDF2F4);
const greyBackground = Color(0xFFF7F7FB);
const greyLight = Color(0xFFD0D0D0);
const grey = Color(0xFF707070);

const BoxShadow shadow = BoxShadow(
  color: Color(0xFFD0D0D0),
  blurRadius: 10,
  offset: Offset(0, 4), // Shadow position
);

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (double strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
